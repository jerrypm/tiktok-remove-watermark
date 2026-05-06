//
//  ViewModifiers.swift
//  tiktok-remove-watermark
//

import SwiftUI

// MARK: - Shadows

/// Two-layer soft shadow used on light-mode cards, matching the design spec.
private struct CardShadowModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        if colorScheme == .dark {
            content
        } else {
            content
                .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
                .shadow(color: .black.opacity(0.05), radius: 24, x: 0, y: 8)
        }
    }
}

/// Lighter shadow for inputs and chips.
private struct FieldShadowModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        if colorScheme == .dark {
            content
        } else {
            content
                .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
                .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: 4)
        }
    }
}

/// Accent-tinted glow behind the primary CTA.
private struct CTAShadowModifier: ViewModifier {
    let accent: Color
    let isVisible: Bool

    func body(content: Content) -> some View {
        if isVisible {
            content.shadow(color: accent.opacity(0.33), radius: 18, x: 0, y: 6)
        } else {
            content
        }
    }
}

extension View {
    func cardShadow() -> some View { modifier(CardShadowModifier()) }
    func fieldShadow() -> some View { modifier(FieldShadowModifier()) }
    func ctaShadow(tint: Color, enabled: Bool) -> some View {
        modifier(CTAShadowModifier(accent: tint, isVisible: enabled))
    }
}

// MARK: - Kerning helper

extension View {
    /// Applies HIG-style negative tracking to a text container.
    func tightTracking(_ value: CGFloat) -> some View {
        tracking(value)
    }
}
