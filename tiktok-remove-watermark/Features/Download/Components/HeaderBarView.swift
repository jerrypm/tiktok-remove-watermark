//
//  HeaderBarView.swift
//  tiktok-remove-watermark
//

import SwiftUI

/// Floating header bar with an accent-tinted download chip on the leading side
/// and an overflow menu chip on the trailing side.
struct HeaderBarView: View {

    var onMenuTapped: () -> Void = {}

    var body: some View {
        HStack {
            accentChip
            Spacer()
            menuChip
        }
    }

    private var accentChip: some View {
        RoundedRectangle(cornerRadius: AppTheme.Radius.headerChip, style: .continuous)
            .fill(chipBackground)
            .frame(width: AppTheme.Size.headerChip, height: AppTheme.Size.headerChip)
            .overlay {
                Image(systemName: "arrow.down.to.line")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.Palette.accent)
            }
            .fieldShadow()
    }

    private var menuChip: some View {
        Button(action: onMenuTapped) {
            Circle()
                .fill(chipBackground)
                .frame(width: AppTheme.Size.headerChip, height: AppTheme.Size.headerChip)
                .overlay {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.Palette.muted)
                }
                .fieldShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("More options")
    }

    private var chipBackground: Color {
        Color(.secondarySystemGroupedBackground)
    }
}

#Preview {
    HeaderBarView()
        .padding()
        .background(Color(.systemGroupedBackground))
}
