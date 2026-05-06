//
//  TitleBlockView.swift
//  tiktok-remove-watermark
//

import SwiftUI

/// Large HIG-style title and subtitle shown at the top of the screen.
struct TitleBlockView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
            Text(AppTheme.Strings.appTitle)
                .font(AppTheme.Typography.largeTitle)
                .tracking(AppTheme.Tracking.largeTitle)
                .foregroundStyle(.primary)

            Text(AppTheme.Strings.appSubtitle)
                .font(AppTheme.Typography.titleBody)
                .tracking(AppTheme.Tracking.caption)
                .foregroundStyle(.secondary)
                .lineLimit(AppTheme.Layout.titleLineLimit)
                .frame(maxWidth: AppTheme.Layout.titleSubtitleMaxWidth, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    TitleBlockView()
        .padding()
        .background(Color(.systemGroupedBackground))
}
