//
//  VideoThumbnail.swift
//  tiktok-remove-watermark
//

import SwiftUI

/// Poster-style thumbnail with a glassy play chip and duration badge overlay.
/// Falls back to a gradient placeholder when the image fails to load.
struct VideoThumbnail: View {

    let coverURL: URL?
    let durationSeconds: Int?

    var body: some View {
        ZStack {
            backgroundImage
            playChip
            durationBadgeOverlay
        }
        .frame(width: AppTheme.Size.thumbnailWidth, height: AppTheme.Size.thumbnailHeight)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.thumbnail, style: .continuous))
    }

    // MARK: - Subviews

    @ViewBuilder
    private var backgroundImage: some View {
        if let coverURL {
            AsyncImage(url: coverURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    gradientPlaceholder
                default:
                    gradientPlaceholder.overlay(ProgressView().tint(.white))
                }
            }
        } else {
            gradientPlaceholder
        }
    }

    private var gradientPlaceholder: some View {
        LinearGradient(
            colors: [
                Color(hex: 0x2A1438),
                Color(hex: 0x4A1F52),
                Color(hex: 0x6B2847),
                Color(hex: 0x8A2F3A)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var playChip: some View {
        Circle()
            .fill(.black.opacity(0.5))
            .frame(width: AppTheme.Size.playChip, height: AppTheme.Size.playChip)
            .overlay {
                Image(systemName: "play.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .offset(x: 1)
            }
            .background(.ultraThinMaterial, in: Circle())
    }

    @ViewBuilder
    private var durationBadgeOverlay: some View {
        if let durationSeconds {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    DurationBadge(seconds: durationSeconds)
                        .padding(.trailing, AppTheme.Spacing.xSmall)
                        .padding(.bottom, AppTheme.Spacing.xSmall)
                }
            }
        }
    }
}

/// Caption-sized timestamp label used in the bottom-right of a thumbnail.
struct DurationBadge: View {
    let seconds: Int

    var body: some View {
        Text(formatted)
            .font(AppTheme.Typography.durationBadge)
            .foregroundStyle(.white)
            .monospacedDigit()
            .padding(.horizontal, AppTheme.Spacing.xSmall)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.durationBadge, style: .continuous)
                    .fill(.black.opacity(0.55))
            )
    }

    private var formatted: String {
        let minutes = seconds / 60
        let remainder = seconds % 60
        return String(format: "%d:%02d", minutes, remainder)
    }
}

#Preview {
    HStack {
        VideoThumbnail(coverURL: nil, durationSeconds: 23)
        VideoThumbnail(
            coverURL: URL(string: "https://picsum.photos/seed/tiktok/200/300"),
            durationSeconds: 87
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
