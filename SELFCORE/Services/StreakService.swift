// Services/StreakService.swift — Feature 2: Streak System
import Foundation
import SwiftUI

@MainActor
class StreakService: ObservableObject {
    static let shared = StreakService()
    private let key = "streakData"

    @Published var data: StreakData = StreakData()
    @Published var showMilestoneCelebration: Bool = false
    @Published var celebratedMilestone: Int = 0

    init() {
        load()
    }

    func load() {
        if let raw = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(StreakData.self, from: raw) {
            data = decoded
        }
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    func recordCheckIn() {
        let wasMilestone = data.isMilestoneDay
        data.recordCheckIn()

        if data.isMilestoneDay && !wasMilestone {
            celebratedMilestone = data.currentStreak
            showMilestoneCelebration = true
            data.celebrateMilestone()
        }
        save()
    }

    func dismissCelebration() {
        showMilestoneCelebration = false
    }

    var streakIsActiveToday: Bool {
        guard let last = data.lastCheckInDate else { return false }
        return Calendar.current.isDateInToday(last)
    }
}
