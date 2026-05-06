//
//  URLField.swift
//  tiktok-remove-watermark
//

import SwiftUI
import UIKit

/// Rounded-pill input for a TikTok share URL, with paste and clear affordances.
/// Matches the 56pt tap-target design spec.
struct URLField: View {

    @Binding var link: String
    let hasError: Bool
    var onPaste: () -> Void = {}
    var onClear: () -> Void = {}
    var onSubmit: () -> Void = {}

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            linkIcon
            textField
            Spacer(minLength: 0)
            trailingControl
        }
        .padding(.leading, AppTheme.Spacing.large)
        .padding(.trailing, AppTheme.Spacing.xSmall)
        .frame(height: AppTheme.Size.touchTarget)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.field, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.Radius.field, style: .continuous)
                .strokeBorder(hasError ? AppTheme.Palette.error : .clear, lineWidth: 1.5)
        }
        .fieldShadow()
    }

    // MARK: - Subviews

    private var linkIcon: some View {
        Image(systemName: "link")
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(hasError ? AppTheme.Palette.error : AppTheme.Palette.muted)
    }

    private var textField: some View {
        TextField(AppTheme.Strings.fieldPlaceholder, text: $link)
            .textFieldStyle(.plain)
            .font(link.isEmpty ? AppTheme.Typography.fieldText : AppTheme.Typography.fieldValue)
            .tracking(AppTheme.Tracking.field)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .keyboardType(.URL)
            .submitLabel(.go)
            .focused($isFocused)
            .onSubmit(onSubmit)
            .lineLimit(1)
    }

    @ViewBuilder
    private var trailingControl: some View {
        if link.isEmpty {
            pasteButton
        } else {
            clearButton
        }
    }

    private var pasteButton: some View {
        Button {
            if let pasted = UIPasteboard.general.string {
                link = pasted
                onPaste()
            }
        } label: {
            HStack(spacing: AppTheme.Spacing.xSmall) {
                Image(systemName: "doc.on.clipboard.fill")
                    .font(.system(size: 12, weight: .semibold))
                Text(AppTheme.Strings.pasteAction)
                    .font(AppTheme.Typography.pasteLabel)
                    .tracking(AppTheme.Tracking.caption)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, AppTheme.Spacing.regular)
            .frame(height: AppTheme.Size.pasteButtonHeight)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.pill, style: .continuous)
                    .fill(AppTheme.Palette.accent)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Paste TikTok link")
    }

    private var clearButton: some View {
        Button(action: onClear) {
            Image(systemName: "xmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(
                    Circle().fill(Color.secondary.opacity(0.5))
                )
        }
        .buttonStyle(.plain)
        .padding(.trailing, AppTheme.Spacing.small)
        .accessibilityLabel("Clear link")
    }
}

#Preview("Empty") {
    URLFieldPreviewWrapper(initial: "", hasError: false)
        .padding()
        .background(Color(.systemGroupedBackground))
}

#Preview("Filled") {
    URLFieldPreviewWrapper(initial: "https://vm.tiktok.com/ZMhK2J8Xp/", hasError: false)
        .padding()
        .background(Color(.systemGroupedBackground))
}

#Preview("Error") {
    URLFieldPreviewWrapper(initial: "https://tiktok.com/xyz", hasError: true)
        .padding()
        .background(Color(.systemGroupedBackground))
}

#if DEBUG
private struct URLFieldPreviewWrapper: View {
    @State var link: String
    let hasError: Bool

    init(initial: String, hasError: Bool) {
        _link = State(initialValue: initial)
        self.hasError = hasError
    }

    var body: some View {
        URLField(link: $link, hasError: hasError)
    }
}
#endif
