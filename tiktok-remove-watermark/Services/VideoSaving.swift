//
//  VideoSaving.swift
//  tiktok-remove-watermark
//

import Foundation

/// Result of attempting to persist the downloaded video.
enum SaveOutcome: Equatable {
    /// Successfully imported into the user's Photos library.
    case savedToPhotos

    /// Photos import failed (typically on the iOS 26 Simulator); the file has
    /// been stashed in the app's `Documents/` folder and can be shared.
    case savedToFiles(fileURL: URL)
}

/// Abstraction over any service that downloads a remote video and persists it
/// somewhere the user can access.
protocol VideoSaving: Sendable {
    func downloadAndSave(from urlString: String) async throws -> SaveOutcome
}
