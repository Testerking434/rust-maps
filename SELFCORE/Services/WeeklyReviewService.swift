// Services/WeeklyReviewService.swift — Feature 9: Wochenrückblick
import Foundation
import SwiftUI

struct WeeklyReviewData {
    var checkInsThisWeek: Int
    var actionsCompleted: Int
    var averageMood: Mood?
    var streakCurrent: Int
    var dimensionHighlight: (DimensionType, Double)?  // dimension + change
    var topMoodCount: [(Mood, Int)]
    var bestDay: String?
    var weekRange: String

    // Fallback demo data
    static let demo = WeeklyReviewData(
        checkInsThisWeek: 5,
        actionsCompleted: 3,
        averageMood: .focused,
        streakCurrent: 7,
        dimensionHighlight: (.klarheit, 0.5),
        topMoodCount: [(.focused, 3), (.energized, 1), (.neutral, 1)],
        bestDay: "Mittwoch",
        weekRange: weekRangeString()
    )

    static func weekRangeString() -> String {
        let cal = Calendar.current
        let now = Date()
        guard let weekStart = cal.dateInterval(of: .weekOfYear, for: now)?.start else { return "" }
        let weekEnd = cal.date(byAdding: .day, value: 6, to: weekStart) ?? now
        let f = DateFormatter()
        f.locale = Locale(identifier: "de_DE")
        f.dateFormat = "d. MMM"
        return "\(f.string(from: weekStart)) – \(f.string(from: weekEnd))"
    }
}

class WeeklyReviewService {
    static func buildReview(checkIns: [CheckIn], streak: StreakData, profile: UserProfile?) -> WeeklyReviewData {
        let cal = Calendar.current
        let now = Date()
        let weekStart = cal.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let thisWeek = checkIns.filter { $0.date >= weekStart }

        let moodCounts = Dictionary(grouping: thisWeek, by: { $0.mood }).mapValues { $0.count }
        let topMood = moodCounts.sorted { $0.value > $1.value }.first?.key
        let topMoodList = moodCounts.sorted { $0.value > $1.value }.map { ($0.key, $0.value) }

        let actionsCompleted = thisWeek.filter { $0.actionCompleted }.count

        // Best day (most positive mood)
        let positiveOrder: [Mood] = [.energized, .focused, .neutral, .tired, .struggling]
        let bestDayCheckIn = thisWeek.min { a, b in
            let ai = positiveOrder.firstIndex(of: a.mood) ?? 99
            let bi = positiveOrder.firstIndex(of: b.mood) ?? 99
            return ai < bi
        }

        var bestDayString: String? = nil
        if let best = bestDayCheckIn {
            let f = DateFormatter()
            f.locale = Locale(identifier: "de_DE")
            f.dateFormat = "EEEE"
            bestDayString = f.string(from: best.date)
        }

        return WeeklyReviewData(
            checkInsThisWeek: thisWeek.count,
            actionsCompleted: actionsCompleted,
            averageMood: topMood,
            streakCurrent: streak.currentStreak,
            dimensionHighlight: nil,  // populated from server if available
            topMoodCount: topMoodList,
            bestDay: bestDayString,
            weekRange: WeeklyReviewData.weekRangeString()
        )
    }
}
