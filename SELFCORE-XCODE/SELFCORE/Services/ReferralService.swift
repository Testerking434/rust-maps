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

    // Stable idempotency keys so repeated calls never double-count server-side
    private let rewardSeenKeyUD  = "rewardSeenIdempotencyKey"
    private let fetchCodeKeyUD   = "fetchCodeIdempotencyKey"

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
            // Use cached data if server is unreachable
        }
    }

    // MARK: - Generate / Get Referral Code

    func fetchOrCreateCode() async {
        isLoading = true
        defer { isLoading = false }

        // Use a stable key so retrying never creates a second code entry
        let key = stableIdempotencyKey(forUD: fetchCodeKeyUD)

        do {
            let data: ReferralData = try await APIService.shared.makeRequest(
                endpoint: "/referral/code",
                method: "POST",
                idempotencyKey: key
            )
            referralData = data
            saveCache(data)
            // Code successfully created/retrieved → clear the key for next install/re-fetch
            clearIdempotencyKey(forUD: fetchCodeKeyUD)
        } catch {
            // Fallback: generate local code; server will validate/reconcile on next fetch
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

Melde dich über meinen Link an — du bekommst 3 Tage GEN:SIGNAL gratis zum Reinschnuppern:

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

        // Use a stable idempotency key so rapidly tapping "dismiss" or a network retry
        // never marks rewards as seen twice (server is a no-op anyway, but belt-and-suspenders).
        let key = stableIdempotencyKey(forUD: rewardSeenKeyUD)

        Task {
            struct Empty: Decodable {}
            let _: Empty? = try? await APIService.shared.makeRequest(
                endpoint: "/referral/rewards/seen",
                method: "POST",
                idempotencyKey: key
            )
            // After a confirmed server round-trip, clear the key
            await MainActor.run {
                self.clearIdempotencyKey(forUD: self.rewardSeenKeyUD)
            }
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

    // MARK: - Idempotency key helpers

    /// Returns the stored key for this slot, or generates + stores a fresh one.
    private func stableIdempotencyKey(forUD key: String) -> String {
        if let existing = UserDefaults.standard.string(forKey: key) { return existing }
        let fresh = UUID().uuidString
        UserDefaults.standard.set(fresh, forKey: key)
        return fresh
    }

    private func clearIdempotencyKey(forUD key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

    // MARK: - Local code fallback (6 chars, unambiguous alphabet)

    private func generateLocalCode() -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }

    // MARK: - Computed Helpers

    var currentBadge: ReferralMilestone? {
        ReferralMilestone.all.last(where: { $0.required <= referralData.totalReferred })
    }

    var totalEarnedDays: Int {
        referralData.totalReferred * 3  // 3 Tage pro erfolgreichem Freund
    }
}
