// Models/Course.swift
import SwiftUI

struct Course: Identifiable, Codable {
    var id: String
    var title: String
    var subtitle: String
    var description: String
    var totalLessons: Int
    var completedLessons: Int
    var color: String  // hex string
    var icon: String   // SF Symbol name
    var isUnlocked: Bool

    var progress: Double {
        guard totalLessons > 0 else { return 0 }
        return Double(completedLessons) / Double(totalLessons)
    }

    var progressPercent: Int { Int(progress * 100) }

    var isCompleted: Bool { completedLessons >= totalLessons }

    var swiftColor: Color { Color(hex: color) }

    // Feature 8: milestone thresholds for animations
    var milestones: [Int] { [5, 10, 20, totalLessons] }

    func reachedMilestone(from old: Int, to new: Int) -> Int? {
        milestones.first { old < $0 && new >= $0 }
    }

    static let allCourses: [Course] = [
        Course(
            id: "awakening",
            title: "AWAKENING",
            subtitle: "Erwache zu dir selbst",
            description: "Der erste Schritt: Erkenne wer du wirklich bist und lege falsche Masken ab.",
            totalLessons: 42,
            completedLessons: 0,
            color: "#F5A623",
            icon: "sun.rise.fill",
            isUnlocked: true
        ),
        Course(
            id: "origin",
            title: "ORIGIN",
            subtitle: "Verstehe deine Wurzeln",
            description: "Deine Vergangenheit erklärt deine Gegenwart. Verarbeite, was dich geformt hat.",
            totalLessons: 36,
            completedLessons: 0,
            color: "#FF6B9D",
            icon: "tree.fill",
            isUnlocked: false
        ),
        Course(
            id: "genesis",
            title: "GENESIS",
            subtitle: "Erschaffe neu",
            description: "Aus den Trümmern alter Muster entsteht eine neue Version von dir.",
            totalLessons: 38,
            completedLessons: 0,
            color: "#4A90D9",
            icon: "sparkles",
            isUnlocked: false
        ),
        Course(
            id: "foundation",
            title: "FOUNDATION",
            subtitle: "Baue unerschütterlich",
            description: "Fundamentale Gewohnheiten und Überzeugungen die dich tragen.",
            totalLessons: 35,
            completedLessons: 0,
            color: "#FF6B35",
            icon: "building.columns.fill",
            isUnlocked: false
        ),
        Course(
            id: "core-journey",
            title: "CORE JOURNEY",
            subtitle: "Deine finale Transformation",
            description: "Alles kommt zusammen. Du wirst nicht derselbe sein wie vorher.",
            totalLessons: 40,
            completedLessons: 0,
            color: "#5CB85C",
            icon: "star.fill",
            isUnlocked: false
        )
    ]
}
