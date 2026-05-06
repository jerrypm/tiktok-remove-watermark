//
//  DownloadViewModel.swift
//  tiktok-remove-watermark
//

import Foundation
import Observation

/// Owns the state of the download flow and coordinates fetching + saving.
@MainActor
@Observable
final class DownloadViewModel {

    var link: String = ""
    private(set) var state: DownloadState = .idle

    private let videoFetcher: TikTokVideoFetching
    private let videoSaver: VideoSaving

    /// Tracks the last URL we successfully started fetching so a rapid
    /// sequence of identical pastes does not trigger duplicate requests.
    private var lastFetchedLink: String?

    init(
        videoFetcher: TikTokVideoFetching = CompositeVideoFetcher([
            TikWMVideoFetcher(),
            SSSTikVideoFetcher()
        ]),
        videoSaver: VideoSaving = PhotoLibraryVideoSaver()
    ) {
        self.videoFetcher = videoFetcher
        self.videoSaver = videoSaver
    }

    // MARK: - Derived State

    var canSave: Bool {
        if case .readyToSave = state { return true }
        return false
    }

    var hasLink: Bool { !trimmedLink.isEmpty }

    private var trimmedLink: String {
        link.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Intents

    /// Fetches video metadata for the currently entered link. Safe to call
    /// repeatedly; duplicates are skipped while a fetch is in flight.
    func fetchVideo() async {
        let target = trimmedLink
        guard !target.isEmpty else { return }
        guard !state.isBusy else { return }
        guard target != lastFetchedLink else { return }

        lastFetchedLink = target
        state = .fetchingMetadata
        do {
            let video = try await videoFetcher.fetchVideo(for: target)
            state = .readyToSave(video)
        } catch {
            state = .failed(message: error.localizedDescription)
        }
    }

    /// Downloads and saves the currently fetched video to Photos.
    func saveVideo() async {
        guard case .readyToSave(let video) = state else { return }
        state = .saving(video)
        do {
            let outcome = try await videoSaver.downloadAndSave(from: video.bestPlaybackURL)
            state = .saved(video, outcome)
        } catch {
            state = .failed(message: error.localizedDescription)
        }
    }

    /// Clears the current input and returns the flow to its initial state.
    func reset() {
        link = ""
        lastFetchedLink = nil
        state = .idle
    }

    /// Clears failure state so the user can fetch again with the same link.
    func retry() {
        lastFetchedLink = nil
        state = .idle
    }
}
