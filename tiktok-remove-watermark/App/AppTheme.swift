//
//  AppTheme.swift
//  tiktok-remove-watermark
//

import SwiftUI

/// Design tokens shared across the app. Mirrors the handoff design spec
/// (iPhone 15, SF Pro, 8pt grid, Apple HIG soft shadows).
enum AppTheme {

    // MARK: - Spacing (8pt grid friendly)

    enum Spacing {
        static let xTight: CGFloat = 2
        static let tight: CGFloat = 4
        static let xSmall: CGFloat = 6
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let regular: CGFloat = 14
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 20
        static let xxLarge: CGFloat = 24
    }

    // MARK: - Radii

    enum Radius {
        static let pill: CGFloat = 10
        static let field: CGFloat = 16
        static let cta: CGFloat = 16
        static let feedbackCard: CGFloat = 18
        static let previewCard: CGFloat = 22
        static let infoCard: CGFloat = 14
        static let thumbnail: CGFloat = 12
        static let headerChip: CGFloat = 10
        static let durationBadge: CGFloat = 4
    }

    // MARK: - Component sizes

    enum Size {
        static let touchTarget: CGFloat = 56
        static let pasteButtonHeight: CGFloat = 38
        static let headerChip: CGFloat = 36
        static let feedbackIcon: CGFloat = 44
        static let loadingRing: CGFloat = 32
        static let thumbnailWidth: CGFloat = 92
        static let thumbnailHeight: CGFloat = 124
        static let playChip: CGFloat = 32
        static let ctaSpinner: CGFloat = 18
        static let avatar: CGFloat = 18
        static let infoBadge: CGFloat = 22
        static let progressBarHeight: CGFloat = 6
    }

    // MARK: - Typography

    enum Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold)
        static let titleBody = Font.system(size: 15, weight: .regular)
        static let cardTitle = Font.system(size: 17, weight: .semibold)
        static let cardSubtitle = Font.system(size: 14, weight: .regular)
        static let ctaLabel = Font.system(size: 17, weight: .semibold)
        static let fieldText = Font.system(size: 17, weight: .regular)
        static let fieldValue = Font.system(size: 15, weight: .regular, design: .monospaced)
        static let metaTitle = Font.system(size: 15, weight: .semibold)
        static let metaCaption = Font.system(size: 13, weight: .regular)
        static let footnote = Font.system(size: 12, weight: .regular)
        static let pasteLabel = Font.system(size: 15, weight: .semibold)
        static let durationBadge = Font.system(size: 10, weight: .semibold)
        static let infoBadgeLetter = Font.system(size: 13, weight: .bold)
        static let infoTitle = Font.system(size: 14, weight: .semibold)
        static let infoBody = Font.system(size: 13, weight: .regular)
    }

    // MARK: - Letter spacing

    enum Tracking {
        static let largeTitle: CGFloat = -0.8
        static let cardTitle: CGFloat = -0.4
        static let field: CGFloat = -0.4
        static let caption: CGFloat = -0.2
    }

    // MARK: - Palette

    enum Palette {
        static let accent = Color(hex: 0x7B3FF2)
        static let success = Color(hex: 0x34C759)
        static let error = Color(hex: 0xFF3B30)
        static let muted = Color(hex: 0x8E8E93)
    }

    // MARK: - Layout

    enum Layout {
        static let titleSubtitleMaxWidth: CGFloat = 300
        static let titleLineLimit = 2
    }

    // MARK: - Strings

    enum Strings {
        static let appTitle = "Save Video"
        static let appSubtitle = "Paste a TikTok link and save it straight to your camera roll."
        static let fieldPlaceholder = "Paste TikTok link"
        static let pasteAction = "Paste"
        static let saveAction = "Save Video"
        static let savingAction = "Saving…"
        static let savedAction = "Saved"
        static let tryAgainAction = "Try again"
        static let qualityLabel = "Quality"
        static let qualityValue = "1080p · No watermark"
        static let savingTitle = "Saving video"
        static let savingSubtitle = "Downloading to camera roll…"
        static let fetchingTitle = "Finding video"
        static let fetchingSubtitle = "Reading TikTok link…"
        static let savedTitle = "Saved to Photos"
        static let savedToFilesTitle = "Saved to Files"
        static let savedToFilesSubtitle = "Photos wouldn’t accept this clip. Share it out from here."
        static let shareAction = "Share video"
        static let errorTitle = "Link not recognized"
        static let infoTitle = "Watermark-free downloads"
        static let infoBody = "Videos are fetched through TikTok's official API and saved at full 1080p."
        static let footerHint = "Recent saves live in Photos → TikTok album"
    }
}
