// Views/Profile/DimensionGrowthView.swift — Feature 3: Dimension Wachstum sichtbar machen
import SwiftUI

struct DimensionGrowthView: View {
    let profile: UserProfile
    let growthData: [(DimensionType, Double, Double)]  // (dimension, old, new)
    @State private var animate = false

    var body: some View {
        VStack(alignment: .leading, spacing: SCSpacing.md) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 12))
                        .foregroundColor(.scSignal)
                    Text("DEIN WACHSTUM")
                        .font(SCFont.caption(11))
                        .foregroundColor(.scTextSecondary)
                        .tracking(1.5)
                }
                Spacer()
                Text("letzte 30 Tage")
                    .font(SCFont.caption(11))
                    .foregroundColor(.scTextSecondary)
            }

            VStack(spacing: SCSpacing.sm) {
                ForEach(growthData, id: \.0) { (dim, old, new) in
                    GrowthRow(dimension: dim, oldValue: old, newValue: new, animate: animate)
                }
            }

            // Total growth summary
            let totalGrowth = growthData.map { $0.2 - $0.1 }.reduce(0, +)
            if totalGrowth > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.scSuccess)
                    Text(String(format: "+%.1f Gesamtwachstum diese Periode", totalGrowth))
                        .font(SCFont.caption(13))
                        .foregroundColor(.scSuccess)
                }
                .padding(.top, 4)
            }
        }
        .padding(SCSpacing.md)
        .scCard()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.8)) { animate = true }
            }
        }
    }
}

struct GrowthRow: View {
    let dimension: DimensionType
    let oldValue: Double
    let newValue: Double
    let animate: Bool

    var delta: Double { newValue - oldValue }
    var deltaFormatted: String {
        delta >= 0
            ? String(format: "+%.1f", delta)
            : String(format: "%.1f", delta)
    }
    var deltaColor: Color { delta >= 0 ? .scSuccess : .scError }

    var body: some View {
        HStack(spacing: SCSpacing.sm) {
            // Icon
            Image(systemName: dimension.icon)
                .font(.system(size: 13))
                .foregroundColor(dimension.color)
                .frame(width: 18)

            // Name
            Text(dimension.displayName)
                .font(SCFont.caption(12))
                .foregroundColor(.scTextSecondary)
                .frame(width: 90, alignment: .leading)

            // Progress bar with old + new
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.scBorder).frame(height: 6)
                    // Old value (darker)
                    Capsule()
                        .fill(dimension.color.opacity(0.3))
                        .frame(width: geo.size.width * (oldValue / 10), height: 6)
                    // New value (full)
                    Capsule()
                        .fill(dimension.color)
                        .frame(width: animate ? geo.size.width * (newValue / 10) : geo.size.width * (oldValue / 10), height: 6)
                        .animation(.easeInOut(duration: 0.9), value: animate)
                }
            }
            .frame(height: 6)

            // Value
            Text(String(format: "%.1f", newValue))
                .font(SCFont.mono(12))
                .foregroundColor(.white)
                .frame(width: 28)

            // Delta badge
            Text(deltaFormatted)
                .font(SCFont.caption(11))
                .foregroundColor(deltaColor)
                .frame(width: 36, alignment: .trailing)
        }
    }
}
