//
//  InfoBannerView.swift
//  tiktok-remove-watermark
//

import SwiftUI

/// Soft muted banner shown in the empty state to educate the user.
struct InfoBannerView: View {

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.small) {
            infoBadge
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xTight) {
                Text(AppTheme.Strings.infoTitle)
                    .font(AppTheme.Typography.infoTitle)
                    .tracking(AppTheme.Tracking.caption)
                    .foregroundStyle(.primary)

                Text(AppTheme.Strings.infoBody)
                    .font(AppTheme.Typography.infoBody)
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.large)
        .padding(.vertical, AppTheme.Spacing.regular)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.infoCard, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground).opacity(0.55))
        )
    }

    private var infoBadge: some View {
        Circle()
            .fill(AppTheme.Palette.accent.opacity(0.13))
            .frame(width: AppTheme.Size.infoBadge, height: AppTheme.Size.infoBadge)
            .overlay {
                Text("i")
                    .font(AppTheme.Typography.infoBadgeLetter)
                    .foregroundStyle(AppTheme.Palette.accent)
            }
    }
}

#Preview {
    InfoBannerView()
        .padding()
        .background(Color(.systemGroupedBackground))
}
