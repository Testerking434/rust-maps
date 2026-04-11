// Views/Profile/ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            ZStack {
                Color.scBackground.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: SCSpacing.lg) {
                        if let profile = appState.profile {
                            ProfileHeaderCard(profile: profile)
                            RadarSection(profile: profile)
                            // Feature 3: Dimension Growth
                            DimensionGrowthView(profile: profile, growthData: appState.dimensionGrowthData())
                            DimensionsList(profile: profile)
                        } else {
                            VStack(spacing: SCSpacing.lg) {
                                ForEach(0..<3) { _ in
                                    RoundedRectangle(cornerRadius: SCRadius.lg)
                                        .fill(Color.scCard)
                                        .frame(height: 120)
                                        .shimmer()
                                }
                            }
                        }
                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, SCSpacing.md)
                }
            }
            .navigationTitle("Mein Profil")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Profile Header
struct ProfileHeaderCard: View {
    let profile: UserProfile

    var body: some View {
        VStack(spacing: SCSpacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [profile.selfcoreType.color, profile.selfcoreType.color.opacity(0.4)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                Text(profile.firstName.prefix(1).uppercased())
                    .font(SCFont.display(36))
                    .foregroundColor(.white)
            }

            VStack(spacing: 6) {
                Text(profile.name)
                    .font(SCFont.headline(20))
                    .foregroundColor(.white)
                HStack(spacing: 8) {
                    Image(systemName: profile.selfcoreType.icon)
                        .font(.system(size: 14))
                        .foregroundColor(profile.selfcoreType.color)
                    Text(profile.selfcoreType.displayName)
                        .font(SCFont.subheadline(15))
                        .foregroundColor(profile.selfcoreType.color)
                }
                Text(profile.selfcoreType.tagline)
                    .font(SCFont.body(13))
                    .foregroundColor(.scTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(SCSpacing.lg)
        .scCard()
    }
}

// MARK: - Radar Chart Section
struct RadarSection: View {
    let profile: UserProfile

    var body: some View {
        VStack(alignment: .leading, spacing: SCSpacing.md) {
            Text("DIMENSIONEN-RADAR")
                .font(SCFont.caption(11))
                .foregroundColor(.scTextSecondary)
                .tracking(1.5)

            RadarChartView(dimensions: profile.dimensions)
                .frame(height: 260)
                .padding(.vertical, SCSpacing.sm)

            // Average score
            HStack {
                Text("Gesamtprofil")
                    .font(SCFont.body(14))
                    .foregroundColor(.scTextSecondary)
                Spacer()
                Text(String(format: "%.1f / 10", profile.dimensions.average))
                    .font(SCFont.headline(16))
                    .foregroundColor(.scGold)
            }
        }
        .padding(SCSpacing.md)
        .scCard()
    }
}

// MARK: - Radar Chart
struct RadarChartView: View {
    let dimensions: Dimensions

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2 - 30
            let sides = 5
            let angle = (2 * Double.pi) / Double(sides)
            let startAngle = -Double.pi / 2

            // Background grid
            for level in [0.25, 0.5, 0.75, 1.0] {
                var path = Path()
                for i in 0..<sides {
                    let a = startAngle + Double(i) * angle
                    let r = radius * level
                    let pt = CGPoint(x: center.x + r * cos(a), y: center.y + r * sin(a))
                    if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
                }
                path.closeSubpath()
                context.stroke(path, with: .color(.white.opacity(0.08)), lineWidth: 1)
            }

            // Axis lines
            for i in 0..<sides {
                let a = startAngle + Double(i) * angle
                var path = Path()
                path.move(to: center)
                path.addLine(to: CGPoint(x: center.x + radius * cos(a), y: center.y + radius * sin(a)))
                context.stroke(path, with: .color(.white.opacity(0.1)), lineWidth: 1)
            }

            // Data polygon
            let values = dimensions.all.map { $0 / 10.0 }
            var dataPath = Path()
            for (i, val) in values.enumerated() {
                let a = startAngle + Double(i) * angle
                let r = radius * val
                let pt = CGPoint(x: center.x + r * cos(a), y: center.y + r * sin(a))
                if i == 0 { dataPath.move(to: pt) } else { dataPath.addLine(to: pt) }
            }
            dataPath.closeSubpath()

            context.fill(dataPath, with: .color(Color.scGold.opacity(0.25)))
            context.stroke(dataPath, with: .color(Color.scGold), lineWidth: 2)

            // Dimension labels + dots
            let labels = ["Selbst\u{00AD}kenntnis", "Authenti\u{00AD}zität", "Klarheit", "Mut", "Ver\u{00AD}bindung"]
            let labelColors: [Color] = [.scSelbstkenntnis, .scAuthentizitaet, .scKlarheit, .scMut, .scVerbindung]

            for i in 0..<sides {
                let a = startAngle + Double(i) * angle
                let val = values[i]
                let r = radius * val

                // Dot
                let dotPt = CGPoint(x: center.x + r * cos(a), y: center.y + r * sin(a))
                context.fill(Circle().path(in: CGRect(x: dotPt.x - 5, y: dotPt.y - 5, width: 10, height: 10)),
                             with: .color(labelColors[i]))

                // Label
                let labelR = radius + 22
                let labelPt = CGPoint(x: center.x + labelR * cos(a), y: center.y + labelR * sin(a))
                context.draw(
                    Text(labels[i]).font(.system(size: 10, weight: .medium)).foregroundColor(labelColors[i]),
                    at: labelPt
                )
            }
        }
    }
}

// MARK: - Dimensions List
struct DimensionsList: View {
    let profile: UserProfile

    var body: some View {
        VStack(spacing: SCSpacing.sm) {
            ForEach(DimensionType.allCases, id: \.self) { dim in
                DimensionRow(
                    dimension: dim,
                    value: profile.dimensions.value(for: dim),
                    isWeakest: dim == profile.dimensions.weakest
                )
            }
        }
    }
}

struct DimensionRow: View {
    let dimension: DimensionType
    let value: Double
    let isWeakest: Bool
    @State private var animateProgress = false

    var body: some View {
        VStack(alignment: .leading, spacing: SCSpacing.sm) {
            HStack {
                Image(systemName: dimension.icon)
                    .font(.system(size: 14))
                    .foregroundColor(dimension.color)
                    .frame(width: 20)
                Text(dimension.displayName)
                    .font(SCFont.subheadline(15))
                    .foregroundColor(.white)
                if isWeakest {
                    Text("Wachstumsfeld")
                        .font(SCFont.caption(10))
                        .foregroundColor(.scGold)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Color.scGold.opacity(0.15))
                        .cornerRadius(6)
                }
                Spacer()
                Text(String(format: "%.1f", value))
                    .font(SCFont.mono(15))
                    .foregroundColor(dimension.color)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.scBorder).frame(height: 7)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [dimension.color, dimension.color.opacity(0.6)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: animateProgress ? geo.size.width * (value / 10) : 0, height: 7)
                        .animation(.easeInOut(duration: 0.8).delay(0.1), value: animateProgress)
                }
            }
            .frame(height: 7)

            Text(dimension.description)
                .font(SCFont.caption(12))
                .foregroundColor(.scTextSecondary)
        }
        .padding(SCSpacing.md)
        .scCard()
        .onAppear { animateProgress = true }
    }
}
