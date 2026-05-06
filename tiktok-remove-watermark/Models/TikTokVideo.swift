//
//  TikTokVideo.swift
//  tiktok-remove-watermark
//

import Foundation

/// Represents a TikTok video's metadata and playback URLs.
struct TikTokVideo: Decodable, Equatable, Sendable {
    let id: String?
    let title: String?
    let play: String          // Standard no-watermark URL
    let hdplay: String?       // HD no-watermark URL
    let wmplay: String?       // Watermarked URL
    let cover: String?
    let duration: Int?
    let author: Author?

    struct Author: Decodable, Equatable, Sendable {
        let uniqueId: String?
        let nickname: String?

        enum CodingKeys: String, CodingKey {
            case uniqueId = "unique_id"
            case nickname
        }
    }

    /// Best available no-watermark URL (HD preferred).
    var bestPlaybackURL: String {
        if let hd = hdplay, !hd.isEmpty { return hd }
        return play
    }
}

#if DEBUG
extension TikTokVideo {
    static let preview = TikTokVideo(
        id: "7000000000000000000",
        title: "Sunset timelapse over the city skyline",
        play: "https://example.com/video.mp4",
        hdplay: "https://example.com/video-hd.mp4",
        wmplay: "https://example.com/video-wm.mp4",
        cover: "https://picsum.photos/seed/tiktok/600/900",
        duration: 28,
        author: Author(uniqueId: "creator", nickname: "Creator")
    )
}
#endif
