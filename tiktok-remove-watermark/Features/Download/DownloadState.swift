//
//  DownloadState.swift
//  tiktok-remove-watermark
//

import Foundation

/// Finite states of the download flow.
enum DownloadState {
    case idle
    case fetchingMetadata
    case readyToSave(TikTokVideo)
    case saving(TikTokVideo)
    case saved(TikTokVideo, SaveOutcome)
    case failed(message: String)
}

extension DownloadState {

    var isFetching: Bool {
        if case .fetchingMetadata = self { return true }
        return false
    }

    var isSaving: Bool {
        if case .saving = self { return true }
        return false
    }

    var isSaved: Bool {
        if case .saved = self { return true }
        return false
    }

    var isFailed: Bool {
        if case .failed = self { return true }
        return false
    }

    var isBusy: Bool { isFetching || isSaving }

    /// The currently known video, if any. Used to keep the preview card visible
    /// across the preview / saving / saved states.
    var video: TikTokVideo? {
        switch self {
        case .readyToSave(let video), .saving(let video):
            return video
        case .saved(let video, _):
            return video
        default:
            return nil
        }
    }
}
