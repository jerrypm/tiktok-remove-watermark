//
//  VideoPreviewCard.swift
//  tiktok-remove-watermark
//

import SwiftUI

/// Card presenting the fetched video's poster, metadata row and quality footer.
struct VideoPreviewCard: View {

    let video: TikTokVideo

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: AppTheme.Spacing.regular) {
                VideoThumbnail(coverURL: coverURL, durationSeconds: video.duration)
                metadata
            }
            .padding(AppTheme.Spacing.regular)

            qualityFooter
        }
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.previewCard, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.previewCard, style: .continuous))
        .cardShadow()
    }

    // MARK: - Derived

    private var coverURL: URL? {
        guard let cover = video.cover, !cover.isEmpty else { return nil }
        return URL(string: cover)
    }

    private var displayTitle: String {
        if let title = video.title?.trimmingCharacters(in: .whitespacesAndNewlines),
           !title.isEmpty {
            return title
        }
        return "TikTok video"
    }

    private var authorHandle: String {
        if let uniqueId = video.author?.uniqueId, !uniqueId.isEmpty {
            return "@\(uniqueId)"
        }
        return video.author?.nickname.map { "@\($0)" } ?? ""
    }

    // MARK: - Subviews

    private var metadata: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
            Text(displayTitle)
                .font(AppTheme.Typography.metaTitle)
                .tracking(-0.3)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            if !authorHandle.isEmpty {
                authorRow
            }

            Spacer(minLength: 0)

            soundRow
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, AppTheme.Spacing.xTight)
    }

    private var authorRow: some View {
        HStack(spacing: AppTheme.Spacing.xSmall) {
            LinearGradient(
                colors: [Color(hex: 0xFF006E), Color(hex: 0x8338EC)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: AppTheme.Size.avatar, height: AppTheme.Size.avatar)
            .clipShape(Circle())

            Text(authorHandle)
                .font(AppTheme.Typography.metaCaption)
                .tracking(AppTheme.Tracking.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var soundRow: some View {
        HStack(spacing: 5) {
            Image(systemName: "music.note")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)

            Text("original sound")
                .font(AppTheme.Typography.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }

    private var qualityFooter: some View {
        HStack {
            Text(AppTheme.Strings.qualityLabel)
                .font(AppTheme.Typography.metaCaption)
                .tracking(AppTheme.Tracking.caption)
                .foregroundStyle(.secondary)

            Spacer()

            HStack(spacing: AppTheme.Spacing.xSmall) {
                Text(AppTheme.Strings.qualityValue)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.large)
        .padding(.vertical, AppTheme.Spacing.small + 2)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.primary.opacity(0.08))
                .frame(height: 0.5)
        }
    }
}

#if DEBUG
#Preview {
    VideoPreviewCard(video: .preview)
        .padding()
        .background(Color(.systemGroupedBackground))
}
#endif
