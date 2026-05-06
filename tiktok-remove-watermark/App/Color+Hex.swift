//
//  Color+Hex.swift
//  tiktok-remove-watermark
//

import SwiftUI

extension Color {
    /// Creates a color from an RGB hex literal, e.g. `Color(hex: 0x7B3FF2)`.
    init(hex: UInt32, opacity: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
