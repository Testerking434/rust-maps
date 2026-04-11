// Views/History/WeeklyReviewView.swift — Feature 9: Wochenrückblick
import SwiftUI

struct WeeklyReviewView: View {
    let review: WeeklyReviewData
    @Environment(\.dismiss) var dismiss
    @State private var animate = false

    var body: some View {
        ZStack {
            Color.scBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: SCSpacing.lg) {
                    // Handle
                    Capsule()
                        .fill(Color.scBorder)
                        .frame(width: 40, height: 4)
                        .padding(.top)

                    // Header
                    VStack(spacing: SCSpacing.sm) {
                        Image(systemName: "chart.bar.doc.horizontal.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.scGold)

                        Text("Dein Wochenrückblick")
                            .font(SCFont.display(26))
                            .foregroundColor(.white)

                        Text(review.weekRange)
                            .font(SCFont.body(14))
                            .foregroundColor(.scTextSecondary)
                    }

                    // Main stats
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: SCSpacing.sm) {
                        ReviewStatCard(
                            icon: "checkmark.circle.fill",
                            value: "\(review.checkInsThisWeek)",
                            label: "Check-ins",
                            color: .scSuccess,
                            animate: animate
                        )
                        ReviewStatCard(
                            icon: "flame.fill",
                            value: "\(review.streakCurrent)",
                            label: "Streak (Tage)",
                            color: .scGold,
                            animate: animate
                        )
                        ReviewStatCard(
                            icon: "bolt.fill",
                            value: "\(review.actionsCompleted)",
                            label: "Aktionen",
                            color: .scMut,
                            animate: animate
                        )
                        ReviewStatCard(
                            icon: "face.smiling.fill",
                            value: review.averageMood?.emoji ?? "—",
                            label: "Domi. Stimmung",
                            color: .scSignal,
                            animate: animate
                        )
                    }

                    // Dimension highlight
                    if let (dim, change) = review.dimensionHighlight {
                        VStack(alignment: .leading, spacing: SCSpacing.sm) {
                            HStack(spacing: 6) {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .foregroundColor(.scSuccess)
                                    .font(.system(size: 13))
                                Text("GRÖSSTER FORTSCHRITT")
                                    .font(SCFont.caption(11))
                                    .foregroundColor(.scTextSecondary)
                                    .tracking(1.5)
                            }
                            HStack(spacing: SCSpacing.sm) {
                                Image(systemName: dim.icon)
                                    .foregroundColor(dim.color)
                                    .font(.system(size: 20))
                                Text(dim.displayName)
                                    .font(SCFont.headline(18))
                                    .foregroundColor(.white)
                                Spacer()
                                Text(String(format: "+%.1f", change))
                                    .font(SCFont.display(22))
                                    .foregroundColor(.scSuccess)
                            }
                        }
                        .padding(SCSpacing.md)
                        .scCard()
                    }

                    // Best day
                    if let day = review.bestDay {
                        VStack(alignment: .leading, spacing: SCSpacing.sm) {
                            Text("BESTER TAG")
                                .font(SCFont.caption(11))
                                .foregroundColor(.scTextSecondary)
                                .tracking(1.5)
                            HStack(spacing: 8) {
                                Text("🌟")
                                    .font(.system(size: 24))
                                Text(day)
                                    .font(SCFont.headline(20))
                                    .foregroundColor(.white)
                                Text("hatte deine beste Energie dieser Woche")
                                    .font(SCFont.body(14))
                                    .foregroundColor(.scTextSecondary)
                            }
                        }
                        .padding(SCSpacing.md)
                        .scCard()
                    }

                    // Mood distribution
                    if !review.topMoodCount.isEmpty {
                        VStack(alignment: .leading, spacing: SCSpacing.sm) {
                            Text("STIMMUNGSVERTEILUNG")
                                .font(SCFont.caption(11))
                                .foregroundColor(.scTextSecondary)
                                .tracking(1.5)

                            ForEach(review.topMoodCount.prefix(5), id: \.0) { (mood, count) in
                                HStack(spacing: SCSpacing.sm) {
                                    Text(mood.emoji).font(.system(size: 18)).frame(width: 28)
                                    Text(mood.label)
                                        .font(SCFont.body(14))
                                        .foregroundColor(.white)
                                        .frame(width: 100, alignment: .leading)
                                    GeometryReader { geo in
                                        let total = review.checkInsThisWeek
                                        let width = total > 0 ? geo.size.width * CGFloat(count) / CGFloat(total) : 0
                                        ZStack(alignment: .leading) {
                                            Capsule().fill(Color.scBorder).frame(height: 8)
                                            Capsule()
                                                .fill(mood.color)
                                                .frame(width: animate ? width : 0, height: 8)
                                                .animation(.easeInOut(duration: 0.8), value: animate)
                                        }
                                    }
                                    .frame(height: 8)
                                    Text("\(count)x")
                                        .font(SCFont.mono(12))
                                        .foregroundColor(.scTextSecondary)
                                        .frame(width: 28)
                                }
                            }
                        }
                        .padding(SCSpacing.md)
                        .scCard()
                    }

                    // Motivational message
                    MotivationalMessage(review: review)

                    Button("Fertig") { dismiss() }
                        .buttonStyle(SCGoldButtonStyle())
                        .padding(.horizontal, SCSpacing.lg)

                    Color.clear.frame(height: 30)
                }
                .padding(.horizontal, SCSpacing.md)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { animate = true }
            }
        }
    }
}

struct ReviewStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let animate: Bool
    @State private var scale: CGFloat = 0.8

    var body: some View {
        VStack(spacing: SCSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            Text(value)
                .font(SCFont.display(28))
                .foregroundColor(.white)
            Text(label)
                .font(SCFont.caption(12))
                .foregroundColor(.scTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(SCSpacing.md)
        .scCard()
        .scaleEffect(animate ? 1.0 : 0.9)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: animate)
    }
}

struct MotivationalMessage: View {
    let review: WeeklyReviewData

    var message: String {
        switch review.checkInsThisWeek {
        case 7:    return "Perfekte Woche! 🔥 Du bist auf dem Weg zur besten Version von dir."
        case 5...6: return "Starke Woche. \(review.checkInsThisWeek)/7 Tage — fast perfekt. Mach weiter!"
        case 3...4: return "Guter Start. Du baust Konsistenz auf. Nächste Woche: 5+ Tage."
        case 1...2: return "Jeder Anfang ist schwer. Eine Sache täglich verändert alles."
        default:    return "Diese Woche wartet auf deinen Check-in. Starte heute."
        }
    }

    var body: some View {
        VStack(spacing: SCSpacing.sm) {
            Text(message)
                .font(SCFont.body(16))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
        }
        .padding(SCSpacing.md)
        .background(
            LinearGradient(
                colors: [Color.scGold.opacity(0.1), Color.scCard],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .cornerRadius(SCRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: SCRadius.lg)
                .stroke(Color.scGold.opacity(0.2), lineWidth: 1)
        )
    }
}
