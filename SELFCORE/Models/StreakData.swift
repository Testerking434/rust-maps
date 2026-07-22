// Models/StreakData.swift — Feature 2: Streak-System
import SwiftUI

struct StreakData: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastCheckInDate: Date?
    var totalCheckIns: Int = 0
    var milestonesCelebrated: [Int] = []

    // Feature 2: Milestone definitions
    static let milestones = [3, 7, 14, 21, 30, 60, 100]

    var nextMilestone: Int? {
        StreakData.milestones.first { $0 > currentStreak }
    }

    var progressToNextMilestone: Double {
        guard let next = nextMilestone else { return 1.0 }
        let prev = StreakData.milestones.last(where: { $0 < currentStreak }) ?? 0
        guard next > prev else { return 0 }
        return Double(currentStreak - prev) / Double(next - prev)
    }

    var streakEmoji: String {
        switch currentStreak {
        case 0:       return "💤"
        case 1...2:   return "🌱"
        case 3...6:   return "🔥"
        case 7...13:  return "⚡️"
        case 14...29: return "💎"
        case 30...59: return "🏆"
        case 60...99: return "👑"
        default:      return "🌟"
        }
    }

    var streakLabel: String {
        switch currentStreak {
        case 0:        return "Starte heute"
        case 1:        return "Erster Tag"
        case 2...6:    return "\(currentStreak) Tage"
        case 7...13:   return "\(currentStreak) Tage 🔥"
        case 14...20:  return "\(currentStreak) Tage ⚡️"
        case 21...29:  return "\(currentStreak) Tage 💎"
        case 30...59:  return "\(currentStreak) Tage 🏆"
        default:       return "\(currentStreak) Tage 👑"
        }
    }

    var milestoneTitle: String {
        switch currentStreak {
        case 3:   return "Erste Woche wird sichtbar"
        case 7:   return "Eine Woche Konsistenz"
        case 14:  return "Zwei Wochen Gewohnheit"
        case 21:  return "Neuer Weg gebahnt"
        case 30:  return "Ein Monat Transformation"
        case 60:  return "Zwei Monate Meisterschaft"
        case 100: return "100 Tage Legende"
        default:  return "Meilenstein erreicht"
        }
    }

    mutating func recordCheckIn(date: Date = Date()) {
        let cal = Calendar.current
        if let last = lastCheckInDate {
            if cal.isDateInToday(last) {
                // Already checked in today
                return
            } else if cal.isDateInYesterday(last) {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        lastCheckInDate = date
        totalCheckIns += 1
    }

    var isMilestoneDay: Bool {
        StreakData.milestones.contains(currentStreak) && !milestonesCelebrated.contains(currentStreak)
    }

    mutating func celebrateMilestone() {
        if !milestonesCelebrated.contains(currentStreak) {
            milestonesCelebrated.append(currentStreak)
        }
    }
}
