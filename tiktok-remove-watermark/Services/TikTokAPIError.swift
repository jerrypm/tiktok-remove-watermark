//
//  TikTokAPIError.swift
//  tiktok-remove-watermark
//

import Foundation

/// Errors emitted while fetching TikTok video metadata.
enum TikTokAPIError: LocalizedError {
    case invalidURL
    case badResponse(statusCode: Int)
    case apiError(message: String)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid TikTok link. Paste a valid share URL."
        case .badResponse(let code):
            return "Server error (HTTP \(code))."
        case .apiError(let message):
            return message
        case .decodingFailed:
            return "Could not parse server response."
        }
    }
}
