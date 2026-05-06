//
//  PhotoLibraryVideoSaver.swift
//  tiktok-remove-watermark
//

import Foundation
import Photos
import UIKit

/// Downloads a remote video to a temporary file, tries to import it into the
/// user's photo library with a short retry loop, and falls back to saving it
/// into the app's `Documents/` folder so the user can still share it.
nonisolated struct PhotoLibraryVideoSaver: VideoSaving {

    private let session: URLSession
    private let fileManager: FileManager
    private let photoLibrary: PHPhotoLibrary
    private let maxPhotoKitAttempts: Int

    init(
        session: URLSession = .shared,
        fileManager: FileManager = .default,
        photoLibrary: PHPhotoLibrary = .shared(),
        maxPhotoKitAttempts: Int = 3
    ) {
        self.session = session
        self.fileManager = fileManager
        self.photoLibrary = photoLibrary
        self.maxPhotoKitAttempts = maxPhotoKitAttempts
    }

    // MARK: - Public entry point

    func downloadAndSave(from urlString: String) async throws -> SaveOutcome {
        print("-=- [Saver] downloadAndSave url=\(urlString)")
        guard let url = URL(string: urlString) else {
            print("-=- [Saver] invalid URL")
            throw VideoSaveError.invalidURL
        }

        let tempFile = try await downloadToTempFile(from: url)
        defer { try? fileManager.removeItem(at: tempFile) }

        try validateVideoFile(at: tempFile)
        try await requestAddOnlyAuthorization()

        if await attemptPhotoLibraryImport(fileURL: tempFile) {
            print("-=- [Saver] DONE — saved to Photos")
            return .savedToPhotos
        }

        let filesURL = try persistToDocuments(tempFile: tempFile)
        print("-=- [Saver] DONE — fell back to Files at \(filesURL.path)")
        return .savedToFiles(fileURL: filesURL)
    }

    // MARK: - Download

    private func downloadToTempFile(from url: URL) async throws -> URL {
        print("-=- [Saver] starting download from host=\(url.host ?? "?")")
        let request = makeRequest(url: url)
        let (sourceURL, response) = try await session.download(for: request)

        if let http = response as? HTTPURLResponse {
            print("-=- [Saver] status=\(http.statusCode)")
            guard (200...299).contains(http.statusCode) else {
                throw VideoSaveError.downloadFailed(statusCode: http.statusCode)
            }
        }

        let destination = fileManager.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")
        try fileManager.moveItem(at: sourceURL, to: destination)
        print("-=- [Saver] moved to \(destination.path)")
        return destination
    }

    private func makeRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue(browserUserAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("video/mp4,video/*;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue(referer(for: url), forHTTPHeaderField: "Referer")
        request.timeoutInterval = 60
        return request
    }

    private func referer(for url: URL) -> String {
        guard let scheme = url.scheme, let host = url.host else {
            return "https://www.tiktok.com/"
        }
        return "\(scheme)://\(host)/"
    }

    // MARK: - Validation

    private func validateVideoFile(at url: URL) throws {
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        let size = (attributes[.size] as? NSNumber)?.int64Value ?? 0
        print("-=- [Saver] downloaded file size=\(size) bytes")

        guard size > 1024 else {
            throw VideoSaveError.saveFailed(reason: "Video file is empty or truncated.")
        }

        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        let head = try handle.read(upToCount: 32) ?? Data()

        guard looksLikeVideo(head) else {
            throw VideoSaveError.saveFailed(
                reason: "Server returned a non-video response. Try another link."
            )
        }
        print("-=- [Saver] byte signature OK")

        let compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
        print("-=- [Saver] UIVideoAtPathIsCompatibleWithSavedPhotosAlbum=\(compatible)")
    }

    private func looksLikeVideo(_ head: Data) -> Bool {
        guard head.count >= 8 else { return false }
        let signatures = ["ftyp", "moov", "mdat", "free", "wide"]
        if let ascii = String(data: head.subdata(in: 4..<8), encoding: .ascii),
           signatures.contains(ascii) {
            return true
        }
        return false
    }

    // MARK: - PhotoKit with retry

    private func requestAddOnlyAuthorization() async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else {
            throw VideoSaveError.permissionDenied
        }
    }

    /// Tries primary + fallback PhotoKit APIs across `maxPhotoKitAttempts`
    /// rounds, waiting briefly between rounds. Simulator `PhotoKit` sometimes
    /// rejects identical input on one call and accepts it on the next.
    private func attemptPhotoLibraryImport(fileURL: URL) async -> Bool {
        for attempt in 1...maxPhotoKitAttempts {
            print("-=- [Saver] PhotoKit attempt #\(attempt)")

            if await tryPrimarySave(fileURL: fileURL) { return true }
            if await tryFallbackSave(fileURL: fileURL) { return true }

            if attempt < maxPhotoKitAttempts {
                try? await Task.sleep(for: .milliseconds(500))
            }
        }
        return false
    }

    private func tryPrimarySave(fileURL: URL) async -> Bool {
        do {
            try await photoLibrary.performChanges {
                PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
            }
            print("-=- [Saver] primary save succeeded")
            return true
        } catch let nsError as NSError {
            print("-=- [Saver] primary failed code=\(nsError.code)")
            return false
        }
    }

    private func tryFallbackSave(fileURL: URL) async -> Bool {
        do {
            try await photoLibrary.performChanges {
                let request = PHAssetCreationRequest.forAsset()
                let options = PHAssetResourceCreationOptions()
                options.shouldMoveFile = false
                request.addResource(with: .video, fileURL: fileURL, options: options)
            }
            print("-=- [Saver] fallback save succeeded")
            return true
        } catch let nsError as NSError {
            print("-=- [Saver] fallback failed code=\(nsError.code)")
            return false
        }
    }

    // MARK: - Files fallback

    /// Copies the successful download into the app's `Documents/` folder with a
    /// sortable, human-friendly filename. The resulting URL can be shared via
    /// `ShareLink` in SwiftUI.
    private func persistToDocuments(tempFile: URL) throws -> URL {
        let documents = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let filename = makeFilename()
        let destination = documents.appendingPathComponent(filename)
        try? fileManager.removeItem(at: destination)
        try fileManager.copyItem(at: tempFile, to: destination)
        return destination
    }

    private func makeFilename() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return "TikTok-\(formatter.string(from: Date())).mp4"
    }

    private var browserUserAgent: String {
        "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) "
        + "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
    }
}
