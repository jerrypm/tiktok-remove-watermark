//
//  VideoSaveError.swift
//  tiktok-remove-watermark
//

import Foundation

/// Errors emitted while downloading and persisting a video to the user's library.
enum VideoSaveError: LocalizedError {
    case invalidURL
    case downloadFailed(statusCode: Int)
    case permissionDenied
    case saveFailed(reason: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid video URL."
        case .downloadFailed(let code):
            return "Download failed (HTTP \(code))."
        case .permissionDenied:
            return "Photos permission denied. Enable it in Settings."
        case .saveFailed(let reason):
            return "Could not save: \(reason)"
        }
    }
}
