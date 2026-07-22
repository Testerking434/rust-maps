// Models/Profile.swift
import SwiftUI

// MARK: - SelfcoreType
enum SelfcoreType: String, Codable, CaseIterable {
    case pioneer    = "PIONEER"
    case guardian   = "GUARDIAN"
    case creator    = "CREATOR"
    case connector  = "CONNECTOR"
    case achiever   = "ACHIEVER"

    var displayName: String {
        switch self {
        case .pioneer:   return "Der Pioneer"
        case .guardian:  return "Der Guardian"
        case .creator:   return "Der Creator"
        case .connector: return "Der Connector"
        case .achiever:  return "Der Achiever"
        }
    }

    var tagline: String {
        switch self {
        case .pioneer:   return "Du siehst Wege, die andere nicht sehen."
        case .guardian:  return "Deine Stärke liegt im Schutz des Wesentlichen."
        case .creator:   return "Du erschaffst Welten aus reiner Vorstellungskraft."
        case .connector: return "Deine Energie verbindet Menschen mit Tiefe."
        case .achiever:  return "Du verwandelst Ziele in Realität."
        }
    }

    var color: Color {
        switch self {
        case .pioneer:   return .scMut
        case .guardian:  return .scKlarheit
        case .creator:   return .scAuthentizitaet
        case .connector: return .scVerbindung
        case .achiever:  return .scSelbstkenntnis
        }
    }

    var icon: String {
        switch self {
        case .pioneer:   return "flame.fill"
        case .guardian:  return "shield.fill"
        case .creator:   return "paintbrush.fill"
        case .connector: return "person.2.fill"
        case .achiever:  return "trophy.fill"
        }
    }

    // Feature 1: Daily energy mode
    var dailyEnergyMode: String {
        switch self {
        case .pioneer:   return "EXPLORE MODE"
        case .guardian:  return "PROTECT MODE"
        case .creator:   return "CREATE MODE"
        case .connector: return "CONNECT MODE"
        case .achiever:  return "ACHIEVE MODE"
        }
    }

    var energyDescription: String {
        switch self {
        case .pioneer:   return "Heute ist dein Tag für neue Wege. Wage den ersten Schritt."
        case .guardian:  return "Heute schützt du was dir wichtig ist. Setze klare Grenzen."
        case .creator:   return "Heute fließt deine Kreativität. Schaffe etwas Bedeutungsvolles."
        case .connector: return "Heute verbindest du. Reiche jemand die Hand."
        case .achiever:  return "Heute erreichst du. Fokus auf dein wichtigstes Ziel."
        }
    }

    // Feature 7: Recommended Signal track by type
    var recommendedSignalTrackId: String {
        switch self {
        case .pioneer:   return "hyperfocus-alpha"
        case .guardian:  return "deep-sleep-delta"
        case .creator:   return "hyperfocus-gamma"
        case .connector: return "burnout-alpha"
        case .achiever:  return "hyperfocus-beta"
        }
    }
}

// MARK: - DimensionType
enum DimensionType: String, Codable, CaseIterable {
    case selbstkenntnis = "selbstkenntnis"
    case authentizitaet = "authentizitaet"
    case klarheit       = "klarheit"
    case mut            = "mut"
    case verbindung     = "verbindung"

    var displayName: String {
        switch self {
        case .selbstkenntnis: return "Selbstkenntnis"
        case .authentizitaet: return "Authentizität"
        case .klarheit:       return "Klarheit"
        case .mut:            return "Mut"
        case .verbindung:     return "Verbindung"
        }
    }

    var color: Color {
        switch self {
        case .selbstkenntnis: return .scSelbstkenntnis
        case .authentizitaet: return .scAuthentizitaet
        case .klarheit:       return .scKlarheit
        case .mut:            return .scMut
        case .verbindung:     return .scVerbindung
        }
    }

    var icon: String {
        switch self {
        case .selbstkenntnis: return "brain.head.profile"
        case .authentizitaet: return "heart.fill"
        case .klarheit:       return "eye.fill"
        case .mut:            return "bolt.fill"
        case .verbindung:     return "person.2.fill"
        }
    }

    var description: String {
        switch self {
        case .selbstkenntnis: return "Wie gut kennst du dich selbst?"
        case .authentizitaet: return "Lebst du nach deinen wahren Werten?"
        case .klarheit:       return "Hast du eine klare Vision?"
        case .mut:            return "Handelst du trotz Unsicherheit?"
        case .verbindung:     return "Wie tief sind deine Beziehungen?"
        }
    }

    // Feature 7: Recommended Signal track by weak dimension
    var recommendedSignalTrackId: String {
        switch self {
        case .selbstkenntnis: return "deep-sleep-delta"
        case .authentizitaet: return "burnout-theta"
        case .klarheit:       return "hyperfocus-gamma"
        case .mut:            return "hyperfocus-alpha"
        case .verbindung:     return "burnout-alpha"
        }
    }
}

// MARK: - Dimensions
struct Dimensions: Codable {
    var selbstkenntnis: Double
    var authentizitaet: Double
    var klarheit: Double
    var mut: Double
    var verbindung: Double

    var all: [Double] { [selbstkenntnis, authentizitaet, klarheit, mut, verbindung] }
    var average: Double { all.reduce(0, +) / Double(all.count) }

    var weakest: DimensionType {
        let vals: [(DimensionType, Double)] = [
            (.selbstkenntnis, selbstkenntnis),
            (.authentizitaet, authentizitaet),
            (.klarheit, klarheit),
            (.mut, mut),
            (.verbindung, verbindung)
        ]
        return vals.min(by: { $0.1 < $1.1 })?.0 ?? .klarheit
    }

    var strongest: DimensionType {
        let vals: [(DimensionType, Double)] = [
            (.selbstkenntnis, selbstkenntnis),
            (.authentizitaet, authentizitaet),
            (.klarheit, klarheit),
            (.mut, mut),
            (.verbindung, verbindung)
        ]
        return vals.max(by: { $0.1 < $1.1 })?.0 ?? .selbstkenntnis
    }

    func value(for type: DimensionType) -> Double {
        switch type {
        case .selbstkenntnis: return selbstkenntnis
        case .authentizitaet: return authentizitaet
        case .klarheit:       return klarheit
        case .mut:            return mut
        case .verbindung:     return verbindung
        }
    }
}

// MARK: - UserProfile
struct UserProfile: Codable {
    var id: String
    var name: String
    var email: String
    var selfcoreType: SelfcoreType
    var dimensions: Dimensions
    var createdAt: Date?

    var firstName: String { name.components(separatedBy: " ").first ?? name }

    static let placeholder = UserProfile(
        id: "preview",
        name: "Max Muster",
        email: "max@example.com",
        selfcoreType: .achiever,
        dimensions: Dimensions(
            selbstkenntnis: 7.2,
            authentizitaet: 5.8,
            klarheit: 8.1,
            mut: 4.3,
            verbindung: 6.9
        ),
        createdAt: Date()
    )
}
