// Views/Home/StreakBannerView.swift — Feature 2: Streak System
import SwiftUI

struct StreakBannerView: View {
    @EnvironmentObject var streakService: StreakService
    @State private var appear = false

    var data: StreakData { streakService.data }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: SCSpacing.md) {
                // Streak count
                VStack(spacing: 4) {
                    Text(data.streakEmoji)
                        .font(.system(size: 32))
                    Text("\(data.currentStreak)")
                        .font(SCFont.display(28))
                        .foregroundColor(streakColor)
                    Text("Tage")
                        .font(SCFont.caption(12))
                        .foregroundColor(.scTextSecondary)
                }
                .frame(width: 70)

                VStack(alignment: .leading, spacing: SCSpacing.sm) {
                    Text(data.streakLabel)
                        .font(SCFont.headline(17))
                        .foregroundColor(.white)

                    // Progress to next milestone
                    if let next = data.nextMilestone {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Nächstes Ziel: \(next) Tage")
                                    .font(SCFont.caption(12))
                                    .foregroundColor(.scTextSecondary)
                                Spacer()
                                Text("\(data.currentStreak)/\(next)")
                                    .font(SCFont.caption(12))
                                    .foregroundColor(.scTextSecondary)
                            }
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.scBorder)
                                        .frame(height: 5)
                                    Capsule()
                                        .fill(streakColor)
                                        .frame(width: geo.size.width * data.progressToNextMilestone, height: 5)
                                        .animation(.easeInOut(duration: 0.8), value: data.progressToNextMilestone)
                                }
                            }
                            .frame(height: 5)
                        }
                    } else {
                        Text("Legende. Kein Limit.")
                            .font(SCFont.caption(13))
                            .foregroundColor(.scGold)
                    }

                    // Longest streak
                    if data.longestStreak > data.currentStreak {
                        Text("Rekord: \(data.longestStreak) Tage")
                            .font(SCFont.caption(11))
                            .foregroundColor(.scTextSecondary.opacity(0.7))
                    }
                }
            }
            .padding(SCSpacing.md)

            // Week dots
            WeekDotsRow()
        }
        .scCard()
        .offset(y: appear ? 0 : 15)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appear = true }
        }
    }

    var streakColor: Color {
        switch data.currentStreak {
        case 0:       return .scTextSecondary
        case 1...6:   return .scGold
        case 7...29:  return .scMut
        case 30...99: return .scSignal
        default:      return .scAuthentizitaet
        }
    }
}

struct WeekDotsRow: View {
    @EnvironmentObject var streakService: StreakService

    var body: some View {
        HStack(spacing: 8) {
            ForEach(last7Days, id: \.self) { date in
                let active = isActive(date)
                let isToday = Calendar.current.isDateInToday(date)
                VStack(spacing: 4) {
                    Circle()
                        .fill(active ? Color.scGold : Color.scBorder)
                        .frame(width: 10, height: 10)
                        .overlay(
                            Circle()
                                .stroke(isToday ? Color.scGold : Color.clear, lineWidth: 2)
                                .frame(width: 14, height: 14)
                        )
                    Text(dayLabel(date))
                        .font(SCFont.caption(9))
                        .foregroundColor(active ? .scGold : .scTextSecondary)
                }
            }
        }
        .padding(.horizontal, SCSpacing.md)
        .padding(.bottom, SCSpacing.sm)
    }

    var last7Days: [Date] {
        (0..<7).reversed().compactMap { Calendar.current.date(byAdding: .day, value: -$0, to: Date()) }
    }

    func isActive(_ date: Date) -> Bool {
        guard let last = streakService.data.lastCheckInDate else { return false }
        // Simple check: was there a check-in on or before this date within streak
        let diff = Calendar.current.dateComponents([.day], from: date, to: last).day ?? 99
        return diff >= 0 && diff < streakService.data.currentStreak
    }

    func dayLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "de_DE")
        f.dateFormat = "E"
        return String(f.string(from: date).prefix(2))
    }
}
