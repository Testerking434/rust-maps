// Views/History/HistoryView.swift
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var streakService: StreakService
    @State private var showWeeklyReview = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.scBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: SCSpacing.md) {
                        // Feature 9: Weekly Review CTA
                        WeeklyReviewCard {
                            showWeeklyReview = true
                        }

                        // Streak overview
                        StreakHistoryCard(data: streakService.data)

                        // Mood history
                        MoodHistoryChart(checkIns: appState.checkIns)

                        // Check-in list
                        CheckInHistoryList(checkIns: appState.checkIns)

                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, SCSpacing.md)
                }
            }
            .navigationTitle("Verlauf")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showWeeklyReview) {
                WeeklyReviewView(review: appState.weeklyReview())
            }
        }
    }
}

// MARK: - Feature 9: Weekly Review Card
struct WeeklyReviewCard: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: SCSpacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.scGold.opacity(0.2))
                        .frame(width: 50, height: 50)
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.system(size: 22))
                        .foregroundColor(.scGold)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Dein Wochenrückblick")
                        .font(SCFont.headline(16))
                        .foregroundColor(.white)
                    Text(WeeklyReviewData.weekRangeString())
                        .font(SCFont.caption(13))
                        .foregroundColor(.scTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.scGold)
            }
            .padding(SCSpacing.md)
            .background(
                LinearGradient(
                    colors: [Color.scGold.opacity(0.1), Color.scCard],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .cornerRadius(SCRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: SCRadius.lg)
                    .stroke(Color.scGold.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Streak History Card
struct StreakHistoryCard: View {
    let data: StreakData

    var body: some View {
        VStack(alignment: .leading, spacing: SCSpacing.md) {
            Text("STREAK ÜBERSICHT")
                .font(SCFont.caption(11))
                .foregroundColor(.scTextSecondary)
                .tracking(1.5)

            HStack(spacing: SCSpacing.lg) {
                StatItem(value: "\(data.currentStreak)", label: "Aktuell", color: .scGold)
                Divider().frame(height: 40).background(Color.scBorder)
                StatItem(value: "\(data.longestStreak)", label: "Rekord", color: .scSignal)
                Divider().frame(height: 40).background(Color.scBorder)
                StatItem(value: "\(data.totalCheckIns)", label: "Gesamt", color: .scVerbindung)
            }
        }
        .padding(SCSpacing.md)
        .scCard()
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(SCFont.display(24))
                .foregroundColor(color)
            Text(label)
                .font(SCFont.caption(12))
                .foregroundColor(.scTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Mood History Chart
struct MoodHistoryChart: View {
    let checkIns: [CheckIn]

    var last7: [CheckIn] {
        checkIns.sorted { $0.date > $1.date }.prefix(7).reversed()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SCSpacing.md) {
            Text("STIMMUNG – LETZTE 7 TAGE")
                .font(SCFont.caption(11))
                .foregroundColor(.scTextSecondary)
                .tracking(1.5)

            if last7.isEmpty {
                Text("Noch keine Check-ins. Starte heute.")
                    .font(SCFont.body(14))
                    .foregroundColor(.scTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, SCSpacing.lg)
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(last7) { checkIn in
                        VStack(spacing: 6) {
                            Text(checkIn.mood.emoji)
                                .font(.system(size: 18))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(checkIn.mood.color.opacity(0.6))
                                .frame(
                                    width: 28,
                                    height: CGFloat(20 + checkIn.mood.healthKitValue * 8)
                                )
                            Text(checkIn.weekday)
                                .font(SCFont.caption(10))
                                .foregroundColor(.scTextSecondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, SCSpacing.sm)
            }
        }
        .padding(SCSpacing.md)
        .scCard()
    }
}

// MARK: - CheckIn History List
struct CheckInHistoryList: View {
    let checkIns: [CheckIn]

    var sorted: [CheckIn] {
        checkIns.sorted { $0.date > $1.date }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SCSpacing.md) {
            Text("ALLE CHECK-INS")
                .font(SCFont.caption(11))
                .foregroundColor(.scTextSecondary)
                .tracking(1.5)

            if sorted.isEmpty {
                Text("Noch keine Check-ins vorhanden.")
                    .font(SCFont.body(14))
                    .foregroundColor(.scTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, SCSpacing.lg)
            } else {
                VStack(spacing: SCSpacing.sm) {
                    ForEach(sorted.prefix(20)) { checkIn in
                        HStack(spacing: SCSpacing.md) {
                            Text(checkIn.mood.emoji)
                                .font(.system(size: 24))

                            VStack(alignment: .leading, spacing: 3) {
                                Text(checkIn.mood.label)
                                    .font(SCFont.subheadline(14))
                                    .foregroundColor(.white)
                                Text(checkIn.dateFormatted)
                                    .font(SCFont.caption(12))
                                    .foregroundColor(.scTextSecondary)
                            }

                            Spacer()

                            if checkIn.actionCompleted {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.scSuccess)
                                        .font(.system(size: 13))
                                    Text("Aktion")
                                        .font(SCFont.caption(11))
                                        .foregroundColor(.scSuccess)
                                }
                            }
                        }
                        .padding(SCSpacing.sm)
                        .scCard()
                    }
                }
            }
        }
    }
}
