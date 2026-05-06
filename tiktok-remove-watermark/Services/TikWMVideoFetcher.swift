//
//  TikWMVideoFetcher.swift
//  tiktok-remove-watermark
//

import Foundation

/// Fetches TikTok video metadata using the public tikwm.com endpoint.
nonisolated struct TikWMVideoFetcher: TikTokVideoFetching {

    private struct Response: Decodable {
        let code: Int
        let msg: String?
        let data: TikTokVideo?
    }

    private let endpoint: URL
    private let session: URLSession

    init(
        endpoint: URL = URL(string: "https://www.tikwm.com/api/")!,
        session: URLSession = .shared
    ) {
        self.endpoint = endpoint
        self.session = session
    }

    func fetchVideo(for shareLink: String) async throws -> TikTokVideo {
        print("-=- [TikWM] fetchVideo input=\(shareLink)")
        guard let cleanedURL = URLExtractor.firstURL(in: shareLink) else {
            print("-=- [TikWM] invalid url")
            throw TikTokAPIError.invalidURL
        }
        print("-=- [TikWM] cleaned=\(cleanedURL)")

        let request = makeRequest(url: cleanedURL)
        let (data, response) = try await session.data(for: request)
        if let http = response as? HTTPURLResponse {
            print("-=- [TikWM] status=\(http.statusCode)")
        }
        if let body = String(data: data, encoding: .utf8) {
            let preview = body.count > 500 ? String(body.prefix(500)) + "…" : body
            print("-=- [TikWM] body preview=\(preview)")
        }
        try validate(response: response)
        let video = try decodeVideo(from: data)
        print("-=- [TikWM] decoded: play=\(video.play)")
        print("-=- [TikWM] decoded: hdplay=\(video.hdplay ?? "nil")")
        print("-=- [TikWM] decoded: bestPlaybackURL=\(video.bestPlaybackURL)")
        return video
    }

    // MARK: - Helpers

    private func makeRequest(url: String) -> URLRequest {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let encoded = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url
        request.httpBody = "url=\(encoded)&hd=1".data(using: .utf8)
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

    private func decodeVideo(from data: Data) throws -> TikTokVideo {
        let parsed: Response
        do {
            parsed = try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw TikTokAPIError.decodingFailed
        }

        guard parsed.code == 0, let video = parsed.data else {
            throw TikTokAPIError.apiError(message: parsed.msg ?? "Request rejected.")
        }
        return video
    }
}
