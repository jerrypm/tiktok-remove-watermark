//
//  SaveCTAButton.swift
//  tiktok-remove-watermark
//

import SwiftUI

/// Multi-state primary call-to-action. Mirrors the label, icon, and enabled
/// treatment described by the design spec (empty / saving / success / error).
struct SaveCTAButton: View {

    enum Mode {
        case idle
        case saving
        case success
        case error
    }

    let mode: Mode
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.small) {
                leadingIcon
                Text(label)
                    .font(AppTheme.Typography.ctaLabel)
                    .tracking(AppTheme.Tracking.cardTitle)
            }
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.Size.touchTarget)
            .foregroundStyle(foreground)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.cta, style: .continuous)
                    .fill(background)
            )
            .ctaShadow(tint: AppTheme.Palette.accent, enabled: showsShadow)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.2), value: mode)
    }

    // MARK: - State Styling

    private var label: String {
        switch mode {
        case .idle: return AppTheme.Strings.saveAction
        case .saving: return AppTheme.Strings.savingAction
        case .success: return AppTheme.Strings.savedAction
        case .error: return AppTheme.Strings.tryAgainAction
        }
    }

    @ViewBuilder
    private var leadingIcon: some View {
        switch mode {
        case .idle:
            Image(systemName: "arrow.down.to.line")
                .font(.system(size: 16, weight: .semibold))
        case .saving:
            ProgressView()
                .controlSize(.small)
                .tint(.white)
                .frame(width: AppTheme.Size.ctaSpinner, height: AppTheme.Size.ctaSpinner)
        case .success:
            Image(systemName: "checkmark")
                .font(.system(size: 16, weight: .bold))
        case .error:
            EmptyView()
        }
    }

    private var foreground: Color {
        isEnabled ? .white : Color.secondary.opacity(0.6)
    }

    private var background: Color {
        isEnabled ? AppTheme.Palette.accent : Color.secondary.opacity(0.15)
    }

    private var showsShadow: Bool {
        isEnabled && mode != .saving
    }
}

#Preview("States") {
    VStack(spacing: 12) {
        SaveCTAButton(mode: .idle, isEnabled: false, action: {})
        SaveCTAButton(mode: .idle, isEnabled: true, action: {})
        SaveCTAButton(mode: .saving, isEnabled: false, action: {})
        SaveCTAButton(mode: .success, isEnabled: false, action: {})
        SaveCTAButton(mode: .error, isEnabled: true, action: {})
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
