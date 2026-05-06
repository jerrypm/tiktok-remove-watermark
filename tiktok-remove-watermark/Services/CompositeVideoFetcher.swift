//
//  CompositeVideoFetcher.swift
//  tiktok-remove-watermark
//

import Foundation

/// Tries a list of fetchers in order, returning the first successful result.
/// Falling back keeps the UX smooth if a particular upstream temporarily fails.
nonisolated struct CompositeVideoFetcher: TikTokVideoFetching {

    let fetchers: [TikTokVideoFetching]

    init(_ fetchers: [TikTokVideoFetching]) {
        self.fetchers = fetchers
    }

    func fetchVideo(for shareLink: String) async throws -> TikTokVideo {
        var lastError: Error?
        for (index, fetcher) in fetchers.enumerated() {
            let name = String(describing: type(of: fetcher))
            print("-=- [Composite] trying fetcher #\(index) \(name)")
            do {
                let video = try await fetcher.fetchVideo(for: shareLink)
                print("-=- [Composite] success from \(name)")
                return video
            } catch {
                print("-=- [Composite] \(name) failed: \(error.localizedDescription)")
                lastError = error
                continue
            }
        }
        throw lastError ?? TikTokAPIError.decodingFailed
    }
}
