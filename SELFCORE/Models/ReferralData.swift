// Models/ReferralData.swift
import SwiftUI

// MARK: - Referral Status
struct ReferralData: Codable {
    var referralCode: String          // z.B. "MAX2K4"
    var referralLink: String          // "https://genselfcore.de/join?ref=MAX2K4"
    var totalReferred: Int            // Wie viele Freunde erfolgreich registriert
    var pendingReferred: Int          // Link geklickt aber noch nicht registriert
    var earnedDays: Int               // Wie viele Gratis-Tage verdient
    var usedByCode: String?           // Wurde dieser User durch ein Ref-Code eingeladen?
    var badges: [ReferralBadge]       // Verdiente Badges
    var rewards: [ReferralReward]     // Alle Belohnungen
    var referredFriends: [ReferredFriend]

    var nextMilestone: ReferralMilestone? {
        ReferralMilestone.all.first { $0.required > totalReferred }
    }

    var progressToNext: Double {
        guard let next = nextMilestone else { return 1.0 }
        let prev = ReferralMilestone.all.last(where: { $0.required < totalReferred })?.required ?? 0
        guard next.required > prev else { return 0 }
        return Double(totalReferred - prev) / Double(next.required - prev)
    }

    static let empty = ReferralData(
        referralCode: "",
        referralLink: "",
        totalReferred: 0,
        pendingReferred: 0,
        earnedDays: 0,
        usedByCode: nil,
        badges: [],
        rewards: [],
        referredFriends: []
    )
}

// MARK: - Referral Milestone
struct ReferralMilestone {
    let required: Int
    let badgeTitle: String
    let badgeEmoji: String
    let badgeColor: Color
    let rewardDescription: String
    let rewardDays: Int               // Gratis-Tage für Signal

    static let all: [ReferralMilestone] = [
        ReferralMilestone(
            required: 1,
            badgeTitle: "CONNECTOR",
            badgeEmoji: "🤝",
            badgeColor: .scVerbindung,
            rewardDescription: "7 Tage GEN:SIGNAL gratis",
            rewardDays: 7
        ),
        ReferralMilestone(
            required: 3,
            badgeTitle: "CATALYST",
            badgeEmoji: "⚡️",
            badgeColor: .scSignal,
            rewardDescription: "3 Wochen GEN:SIGNAL gratis + exklusiver Track",
            rewardDays: 21
        ),
        ReferralMilestone(
            required: 5,
            badgeTitle: "PIONEER",
            badgeEmoji: "🔥",
            badgeColor: .scMut,
            rewardDescription: "2 Monate GEN:SIGNAL gratis",
            rewardDays: 60
        ),
        ReferralMilestone(
            required: 10,
            badgeTitle: "LEGEND",
            badgeEmoji: "👑",
            badgeColor: .scGold,
            rewardDescription: "6 Monate GEN:SIGNAL gratis + LEGEND-Status",
            rewardDays: 180
        ),
    ]
}

// MARK: - Referral Badge
struct ReferralBadge: Codable, Identifiable {
    var id: String
    var title: String
    var emoji: String
    var earnedAt: Date
    var colorHex: String
}

// MARK: - Referral Reward
struct ReferralReward: Codable, Identifiable {
    var id: String
    var type: RewardType
    var description: String
    var daysGranted: Int
    var earnedAt: Date
    var isNew: Bool

    enum RewardType: String, Codable {
        case signalDays  = "signal_days"
        case badge       = "badge"
        case exclusiveTrack = "exclusive_track"
    }
}

// MARK: - Referred Friend
struct ReferredFriend: Codable, Identifiable {
    var id: String
    var firstName: String
    var joinedAt: Date
    var isActive: Bool                // Hat er die App wirklich genutzt?
    var avatarColor: String           // Zufällige Farbe für Avatar

    var avatarSwiftColor: Color { Color(hex: avatarColor) }
    var formattedDate: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "de_DE")
        f.dateStyle = .medium
        return f.string(from: joinedAt)
    }
}
