//
//  SSSTikVideoFetcher.swift
//  tiktok-remove-watermark
//

import Foundation

/// Fetches TikTok video metadata by scraping ssstik.io's htmx endpoint.
/// Returns a direct, no-watermark MP4 URL hosted on tikcdn.io.
nonisolated struct SSSTikVideoFetcher: TikTokVideoFetching {

    private let endpoint: URL
    private let session: URLSession

    init(
        endpoint: URL = URL(string: "https://ssstik.io/abc?url=dl")!,
        session: URLSession = .shared
    ) {
        self.endpoint = endpoint
        self.session = session
    }

    func fetchVideo(for shareLink: String) async throws -> TikTokVideo {
        guard let cleanedURL = URLExtractor.firstURL(in: shareLink) else {
            throw TikTokAPIError.invalidURL
        }

        let request = makeRequest(url: cleanedURL)
        let (data, response) = try await session.data(for: request)
        try validate(response: response)

        guard let html = String(data: data, encoding: .utf8) else {
            throw TikTokAPIError.decodingFailed
        }
        return try parseVideo(from: html)
    }

    // MARK: - Helpers

    private func makeRequest(url: String) -> URLRequest {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("true", forHTTPHeaderField: "HX-Request")
        request.setValue("https://ssstik.io", forHTTPHeaderField: "Origin")
        request.setValue("https://ssstik.io/", forHTTPHeaderField: "Referer")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        let encoded = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url
        request.httpBody = "id=\(encoded)&locale=en&tt=".data(using: .utf8)
        return request
    }

    private func validate(response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw TikTokAPIError.badResponse(statusCode: -1)
        }
        guard (200...299).contains(http.statusCode) else {
            throw TikTokAPIError.badResponse(statusCode: http.statusCode)
        }
    }

    private func parseVideo(from html: String) throws -> TikTokVideo {
        guard let playURL = firstMatch(
            in: html,
            pattern: #"href="(https://tikcdn\.io/ssstik/[^"]+)""#
        ) else {
            throw TikTokAPIError.apiError(
                message: "Could not parse video from ssstik response."
            )
        }

        let rawTitle = firstMatch(in: html, pattern: #"<p class="maintext">([^<]+)</p>"#)
        let rawAuthor = firstMatch(in: html, pattern: #"<h2>([^<]+)</h2>"#)
        let cover = firstMatch(
            in: html,
            pattern: #"background-image:\s*url\((https://[^)]+)\)"#
        )?.trimmingCharacters(in: .whitespacesAndNewlines)

        return TikTokVideo(
            id: nil,
            title: rawTitle?.htmlDecoded,
            play: playURL,
            hdplay: nil,
            wmplay: nil,
            cover: cover,
            duration: nil,
            author: TikTokVideo.Author(
                uniqueId: nil,
                nickname: rawAuthor?.htmlDecoded
            )
        )
    }

    private func firstMatch(in text: String, pattern: String) -> String? {
        guard
            let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
        else {
            return nil
        }
        let fullRange = NSRange(text.startIndex..., in: text)
        guard
            let match = regex.firstMatch(in: text, range: fullRange),
            match.numberOfRanges >= 2,
            let captured = Range(match.range(at: 1), in: text)
        else {
            return nil
        }
        return String(text[captured])
    }

    private var userAgent: String {
        "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) "
        + "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
    }
}

// MARK: - Minimal HTML entity decoding

private extension String {
    var htmlDecoded: String {
        var result = self
        let entities: [(String, String)] = [
            ("&amp;", "&"),
            ("&lt;", "<"),
            ("&gt;", ">"),
            ("&quot;", "\""),
            ("&#39;", "'"),
            ("&apos;", "'"),
            ("&nbsp;", " ")
        ]
        for (entity, replacement) in entities {
            result = result.replacingOccurrences(of: entity, with: replacement)
        }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
