// Services/ReferralService.swift
import Foundation
import SwiftUI

@MainActor
class ReferralService: ObservableObject {
    static let shared = ReferralService()

    @Published var referralData: ReferralData = .empty
    @Published var isLoading = false
    @Published var showNewReward = false
    @Published var latestReward: ReferralReward? = nil

    private let cacheKey = "cachedReferralData"

    init() { loadCache() }

    // MARK: - Load from server
    func loadReferralData() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let data: ReferralData = try await APIService.shared.makeRequest(endpoint: "/referral/data")
            referralData = data
            saveCache(data)
            checkForNewRewards(data)
        } catch {
            // Use cached data if server fails
        }
    }

    // MARK: - Generate / Get Referral Link
    func fetchOrCreateCode() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let data: ReferralData = try await APIService.shared.makeRequest(
                endpoint: "/referral/code",
                method: "POST"
            )
            referralData = data
            saveCache(data)
        } catch {
            // Generate local fallback code (server will validate later)
            if referralData.referralCode.isEmpty {
                let code = generateLocalCode()
                referralData.referralCode = code
                referralData.referralLink = "https://genselfcore.de/join?ref=\(code)"
            }
        }
    }

    // MARK: - Share Sheet Items
    func shareItems(userName: String) -> [Any] {
        let link = referralData.referralLink.isEmpty
            ? "https://genselfcore.de/join"
            : referralData.referralLink

        let message = """
Ich nutze GEN:SELFCORE für meine persönliche Entwicklung — und es verändert wirklich etwas.

Der DNA-Test zeigt dir dein Persönlichkeitsprofil, deine 5 Dimensionen und deinen Wachstumsweg.

Melde dich über meinen Link an — du bekommst 7 Tage GEN:SIGNAL gratis:

\(link)

— \(userName)
"""
        return [message]
    }

    // MARK: - New Reward Notification
    private func checkForNewRewards(_ data: ReferralData) {
        let newReward = data.rewards.first(where: { $0.isNew })
        if let reward = newReward {
            latestReward = reward
            showNewReward = true
        }
    }

    func dismissNewReward() {
        showNewReward = false
        latestReward = nil
        Task {
            // Mark reward as seen on server
            struct Empty: Decodable {}
            let _: Empty? = try? await APIService.shared.makeRequest(
                endpoint: "/referral/rewards/seen",
                method: "POST"
            )
        }
    }

    // MARK: - Cache
    private func loadCache() {
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let decoded = try? JSONDecoder().decode(ReferralData.self, from: data) {
            referralData = decoded
        }
    }

    private func saveCache(_ data: ReferralData) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
        }
    }

    // Local code fallback (6 Zeichen)
    private func generateLocalCode() -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }

    // MARK: - Computed Helpers
    var currentBadge: ReferralMilestone? {
        ReferralMilestone.all.last(where: { $0.required <= referralData.totalReferred })
    }

    var totalEarnedDays: Int {
        referralData.totalReferred * 7
    }
}
