//
//  URLExtractor.swift
//  tiktok-remove-watermark
//

import Foundation

/// Utility for pulling HTTP(S) URLs out of free-form pasted text.
enum URLExtractor {

    /// Returns the first HTTP(S) URL found in `text`, or `nil` if none is present.
    static func firstURL(in text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let range = trimmed.range(of: #"https?://[^\s]+"#, options: .regularExpression) {
            return String(trimmed[range])
        }
        return trimmed.lowercased().hasPrefix("http") ? trimmed : nil
    }
}
