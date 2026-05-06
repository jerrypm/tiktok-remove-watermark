//
//  FeedbackCard.swift
//  tiktok-remove-watermark
//

import SwiftUI

/// Status card rendered below the preview during loading / success / error states.
struct FeedbackCard: View {

    enum Style {
        case fetching
        case saving
        case success(detail: String?)
        case savedToFiles(fileURL: URL, detail: String?)
        case error(message: String)
    }

    let style: Style

    var body: some View {
        container {
            switch style {
            case .fetching:
                loadingRow(
                    title: AppTheme.Strings.fetchingTitle,
                    subtitle: AppTheme.Strings.fetchingSubtitle
                )
            case .saving:
                VStack(alignment: .leading, spacing: 0) {
                    loadingRow(
                        title: AppTheme.Strings.savingTitle,
                        subtitle: AppTheme.Strings.savingSubtitle
                    )
                    indeterminateProgressBar
                        .padding(.top, AppTheme.Spacing.regular)
                }
            case .success(let detail):
                iconRow(
                    systemName: "checkmark",
                    tint: AppTheme.Palette.success,
                    title: AppTheme.Strings.savedTitle,
                    subtitle: detail
                )
            case .savedToFiles(let fileURL, let detail):
                filesSavedRow(fileURL: fileURL, detail: detail)
            case .error(let message):
                iconRow(
                    systemName: "exclamationmark",
                    tint: AppTheme.Palette.error,
                    title: AppTheme.Strings.errorTitle,
                    subtitle: message
                )
            }
        }
    }

    // MARK: - Layouts

    private func container<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(.horizontal, AppTheme.Spacing.large + 2)
        .padding(.vertical, AppTheme.Spacing.large + 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.feedbackCard, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .cardShadow()
    }

    private func loadingRow(title: String, subtitle: String) -> some View {
        HStack(alignment: .center, spacing: AppTheme.Spacing.regular) {
            ProgressView()
                .controlSize(.regular)
                .tint(AppTheme.Palette.accent)
                .frame(width: AppTheme.Size.loadingRing, height: AppTheme.Size.loadingRing)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xTight) {
                Text(title)
                    .font(AppTheme.Typography.cardTitle)
                    .tracking(AppTheme.Tracking.cardTitle)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(AppTheme.Typography.cardSubtitle)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
    }

    private func iconRow(
        systemName: String,
        tint: Color,
        title: String,
        subtitle: String?
    ) -> some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.regular) {
            ZStack {
                Circle()
                    .fill(tint)
                    .frame(width: AppTheme.Size.feedbackIcon, height: AppTheme.Size.feedbackIcon)
                Image(systemName: systemName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xTight) {
                Text(title)
                    .font(AppTheme.Typography.cardTitle)
                    .tracking(AppTheme.Tracking.cardTitle)
                    .foregroundStyle(.primary)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(AppTheme.Typography.cardSubtitle)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.top, 1)

            Spacer(minLength: 0)
        }
    }

    private func filesSavedRow(fileURL: URL, detail: String?) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.regular) {
            iconRow(
                systemName: "folder.fill",
                tint: AppTheme.Palette.accent,
                title: AppTheme.Strings.savedToFilesTitle,
                subtitle: detail ?? AppTheme.Strings.savedToFilesSubtitle
            )

            ShareLink(item: fileURL) {
                HStack(spacing: AppTheme.Spacing.xSmall) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 15, weight: .semibold))
                    Text(AppTheme.Strings.shareAction)
                        .font(AppTheme.Typography.cardSubtitle)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.pill, style: .continuous)
                        .fill(AppTheme.Palette.accent)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var indeterminateProgressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.primary.opacity(0.06))

                IndeterminateBar(accent: AppTheme.Palette.accent, width: proxy.size.width)
            }
        }
        .frame(height: AppTheme.Size.progressBarHeight)
        .clipShape(RoundedRectangle(cornerRadius: 3))
    }
}

/// Animated sliding bar used as an indeterminate progress indicator.
private struct IndeterminateBar: View {
    let accent: Color
    let width: CGFloat

    @State private var offset: CGFloat = -1

    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(accent)
            .frame(width: width * 0.35, height: AppTheme.Size.progressBarHeight)
            .offset(x: offset * width)
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    offset = 1.1
                }
            }
    }
}

#Preview("Saving") {
    FeedbackCard(style: .saving)
        .padding()
        .background(Color(.systemGroupedBackground))
}

#Preview("Success") {
    FeedbackCard(style: .success(detail: "00:23 · 1080p"))
        .padding()
        .background(Color(.systemGroupedBackground))
}

#Preview("Files Fallback") {
    FeedbackCard(
        style: .savedToFiles(
            fileURL: URL(fileURLWithPath: "/tmp/TikTok-preview.mp4"),
            detail: nil
        )
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Error") {
    FeedbackCard(style: .error(message: "Make sure you copied a public TikTok video URL."))
        .padding()
        .background(Color(.systemGroupedBackground))
}
