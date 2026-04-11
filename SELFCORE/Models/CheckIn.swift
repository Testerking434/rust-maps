// Models/CheckIn.swift
import SwiftUI

enum Mood: String, Codable, CaseIterable {
    case energized  = "energized"
    case focused    = "focused"
    case neutral    = "neutral"
    case tired      = "tired"
    case struggling = "struggling"

    var emoji: String {
        switch self {
        case .energized:  return "🔥"
        case .focused:    return "🎯"
        case .neutral:    return "😐"
        case .tired:      return "😴"
        case .struggling: return "💪"
        }
    }

    var label: String {
        switch self {
        case .energized:  return "Energetisch"
        case .focused:    return "Fokussiert"
        case .neutral:    return "Neutral"
        case .tired:      return "Müde"
        case .struggling: return "Im Kampf"
        }
    }

    var message: String {
        switch self {
        case .energized:  return "Nutze diese Energie für deinen wichtigsten Task."
        case .focused:    return "Perfekter Zustand. Tauche tief ein."
        case .neutral:    return "Neutral ist okay. Kleine Schritte zählen."
        case .tired:      return "Hör auf deinen Körper. Ruhe ist auch Fortschritt."
        case .struggling: return "Jeder große Durchbruch entsteht im Widerstand."
        }
    }

    var color: Color {
        switch self {
        case .energized:  return .scMut
        case .focused:    return .scSignal
        case .neutral:    return .scTextSecondary
        case .tired:      return .scKlarheit
        case .struggling: return .scAuthentizitaet
        }
    }

    // Feature 10: HealthKit numeric value (0-10 wellbeing scale)
    var healthKitValue: Double {
        switch self {
        case .energized:  return 9.0
        case .focused:    return 8.0
        case .neutral:    return 6.0
        case .tired:      return 4.0
        case .struggling: return 3.0
        }
    }
}

struct CheckIn: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var mood: Mood
    var actionCompleted: Bool
    var note: String?

    var dateFormatted: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "de_DE")
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: date)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var weekday: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "de_DE")
        f.dateFormat = "E"
        return f.string(from: date)
    }
}
