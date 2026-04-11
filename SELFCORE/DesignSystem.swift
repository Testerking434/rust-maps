// DesignSystem.swift
// SELFCORE – Farben, Fonts, Abstände

import SwiftUI

// MARK: - Colors
extension Color {
    static let scBackground   = Color(hex: "#0A0A0A")
    static let scCard         = Color(hex: "#141414")
    static let scCardElevated = Color(hex: "#1E1E1E")
    static let scGold         = Color(hex: "#F5A623")
    static let scGoldDark     = Color(hex: "#C47D0E")
    static let scSignal       = Color(hex: "#00C9C9")
    static let scSignalDark   = Color(hex: "#007A7A")
    static let scText         = Color.white
    static let scTextSecondary = Color(hex: "#888888")
    static let scBorder       = Color(hex: "#2A2A2A")
    static let scSuccess      = Color(hex: "#34C759")
    static let scWarning      = Color(hex: "#FF9500")
    static let scError        = Color(hex: "#FF3B30")

    // Dimension Colors
    static let scSelbstkenntnis  = Color(hex: "#F5A623") // Gold
    static let scAuthentizitaet  = Color(hex: "#FF6B9D") // Pink
    static let scKlarheit        = Color(hex: "#4A90D9") // Blue
    static let scMut             = Color(hex: "#FF6B35") // Orange-Red
    static let scVerbindung      = Color(hex: "#5CB85C") // Green

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography
struct SCFont {
    static func display(_ size: CGFloat) -> Font     { .system(size: size, weight: .black, design: .default) }
    static func headline(_ size: CGFloat) -> Font    { .system(size: size, weight: .bold, design: .default) }
    static func subheadline(_ size: CGFloat) -> Font { .system(size: size, weight: .semibold, design: .default) }
    static func body(_ size: CGFloat) -> Font        { .system(size: size, weight: .regular, design: .default) }
    static func caption(_ size: CGFloat) -> Font     { .system(size: size, weight: .medium, design: .default) }
    static func mono(_ size: CGFloat) -> Font        { .system(size: size, weight: .medium, design: .monospaced) }
}

// MARK: - Spacing
struct SCSpacing {
    static let xs: CGFloat  = 4
    static let sm: CGFloat  = 8
    static let md: CGFloat  = 16
    static let lg: CGFloat  = 24
    static let xl: CGFloat  = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
struct SCRadius {
    static let sm: CGFloat  = 8
    static let md: CGFloat  = 12
    static let lg: CGFloat  = 16
    static let xl: CGFloat  = 20
    static let xxl: CGFloat = 28
}

// MARK: - Card Modifier
struct SCCardModifier: ViewModifier {
    var elevated: Bool = false
    func body(content: Content) -> some View {
        content
            .background(elevated ? Color.scCardElevated : Color.scCard)
            .cornerRadius(SCRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: SCRadius.lg)
                    .stroke(Color.scBorder, lineWidth: 0.5)
            )
    }
}
extension View {
    func scCard(elevated: Bool = false) -> some View {
        self.modifier(SCCardModifier(elevated: elevated))
    }
}

// MARK: - Gold Button
struct SCGoldButtonStyle: ButtonStyle {
    var fullWidth: Bool = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SCFont.headline(16))
            .foregroundColor(.black)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.vertical, 16)
            .padding(.horizontal, fullWidth ? 0 : 24)
            .background(
                LinearGradient(
                    colors: [Color.scGold, Color.scGoldDark],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(SCRadius.md)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    let active: Bool
    func body(content: Content) -> some View {
        if active {
            content
                .overlay(
                    GeometryReader { geo in
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.3), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geo.size.width * 2)
                        .offset(x: -geo.size.width + phase * geo.size.width * 2)
                    }
                    .clipped()
                )
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
        } else {
            content
        }
    }
}
extension View {
    func shimmer(active: Bool = true) -> some View {
        self.modifier(ShimmerModifier(active: active))
    }
}
