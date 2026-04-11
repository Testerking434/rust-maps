// AppState.swift
import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    // MARK: - Auth
    @Published var isLoggedIn: Bool = false
    @Published var showOnboarding: Bool = true

    // MARK: - Data
    @Published var profile: UserProfile? = nil
    @Published var courses: [Course] = Course.allCourses
    @Published var checkIns: [CheckIn] = []
    @Published var todayCheckIn: CheckIn? = nil
    @Published var isLoadingProfile: Bool = false

    // MARK: - Services
    let streakService = StreakService.shared
    let subscriptionService = SubscriptionService.shared
    let healthKitService = HealthKitService.shared
    let referralService = ReferralService.shared

    // Referral badge count (ungesehene Rewards)
    var referralBadgeCount: Int {
        referralService.referralData.rewards.filter { $0.isNew }.count
    }

    init() {
        loadFromCache()
        if isLoggedIn {
            Task { await refreshData() }
        }
    }

    // MARK: - Login
    func login(email: String, password: String) async throws {
        let response = try await APIService.shared.login(email: email, password: password)
        APIConfig.token = response.token
        self.profile = response.user
        self.isLoggedIn = true
        cacheProfile(response.user)
        Task { await refreshData() }
    }

    func logout() {
        APIConfig.token = nil
        profile = nil
        courses = Course.allCourses
        checkIns = []
        todayCheckIn = nil
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: "cachedProfile")
    }

    // MARK: - Data Refresh
    func refreshData() async {
        isLoadingProfile = true
        defer { isLoadingProfile = false }
        do {
            async let prof = APIService.shared.fetchProfile()
            async let cour = APIService.shared.fetchCourses()
            let (p, c) = try await (prof, cour)
            profile = p
            courses = c
            cacheProfile(p)
        } catch {
            print("Data refresh error: \(error)")
        }
    }

    // MARK: - Check-In
    var hasCheckedInToday: Bool {
        checkIns.contains { $0.isToday }
    }

    func submitCheckIn(mood: Mood, actionCompleted: Bool = false) async {
        let checkIn = CheckIn(date: Date(), mood: mood, actionCompleted: actionCompleted)
        checkIns.append(checkIn)
        todayCheckIn = checkIn
        saveCheckInsLocally()

        // Feature 2: Record streak
        streakService.recordCheckIn()

        // Feature 10: Log to HealthKit
        healthKitService.logMoodCheckIn(mood: mood)

        // Push to server (fire and forget)
        Task {
            try? await APIService.shared.postCheckIn(checkIn)
        }
    }

    func markActionComplete() {
        guard let today = checkIns.firstIndex(where: { $0.isToday }) else { return }
        checkIns[today].actionCompleted = true
        todayCheckIn = checkIns[today]
        saveCheckInsLocally()
        Task { try? await APIService.shared.postCheckIn(checkIns[today]) }
    }

    // MARK: - Persistence
    private func loadFromCache() {
        if let data = UserDefaults.standard.data(forKey: "cachedProfile"),
           let p = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = p
            isLoggedIn = APIConfig.token != nil
        }
        if let data = UserDefaults.standard.data(forKey: "checkIns"),
           let c = try? JSONDecoder().decode([CheckIn].self, from: data) {
            checkIns = c
            todayCheckIn = c.first(where: { $0.isToday })
        }
        if let data = UserDefaults.standard.data(forKey: "courses"),
           let c = try? JSONDecoder().decode([Course].self, from: data) {
            courses = c
        }
    }

    private func cacheProfile(_ profile: UserProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "cachedProfile")
        }
    }

    func saveCheckInsLocally() {
        if let encoded = try? JSONEncoder().encode(checkIns) {
            UserDefaults.standard.set(encoded, forKey: "checkIns")
        }
    }

    // MARK: - Feature 3: Dimension Growth
    func dimensionGrowthData() -> [(DimensionType, Double, Double)] {
        // Returns [(dimension, oldValue, newValue)]
        // In a real app this comes from server history
        guard let profile = profile else { return [] }
        return DimensionType.allCases.map { dim in
            let current = profile.dimensions.value(for: dim)
            let simulatedOld = max(0, current - Double.random(in: 0...1.5))
            return (dim, simulatedOld, current)
        }
    }

    // MARK: - Feature 9: Weekly Review
    func weeklyReview() -> WeeklyReviewData {
        WeeklyReviewService.buildReview(
            checkIns: checkIns,
            streak: streakService.data,
            profile: profile
        )
    }
}
