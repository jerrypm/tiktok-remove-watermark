//
//  TikTokVideoFetching.swift
//  tiktok-remove-watermark
//

import Foundation

/// Abstraction over any service that returns TikTok video metadata for a share link.
protocol TikTokVideoFetching: Sendable {
    func fetchVideo(for shareLink: String) async throws -> TikTokVideo
}
