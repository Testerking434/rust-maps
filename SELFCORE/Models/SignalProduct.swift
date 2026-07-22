// Models/SignalProduct.swift
import SwiftUI

struct AudioTrack: Identifiable, Codable {
    var id: String
    var title: String
    var duration: String        // e.g. "45 Min"
    var frequency: String       // e.g. "Delta 0.5-4Hz"
    var description: String
    var streamURL: String
    var coverColor: String      // hex
    var dimension: String?      // which SELFCORE dimension this supports

    var swiftColor: Color { Color(hex: coverColor) }
}

struct SignalProduct: Identifiable, Codable {
    var id: String
    var name: String
    var subtitle: String
    var tagline: String
    var audioTracks: [AudioTrack]
    var includedInSub: Bool

    static let allProducts: [SignalProduct] = [
        SignalProduct(
            id: "deep-sleep",
            name: "DEEP SLEEP PROTOCOL",
            subtitle: "Schlafe wie nie zuvor",
            tagline: "Delta-Wellen für tiefen regenerativen Schlaf",
            audioTracks: [
                AudioTrack(
                    id: "deep-sleep-delta",
                    title: "Delta Depth",
                    duration: "60 Min",
                    frequency: "Delta 0.5–4 Hz",
                    description: "Tiefschlaf-Induktion durch Delta-Wellen. Optimal als Einschlafhilfe.",
                    streamURL: "https://api.genselfcore.de/v1/signal/deep-sleep-delta",
                    coverColor: "#1A2980",
                    dimension: "klarheit"
                ),
                AudioTrack(
                    id: "deep-sleep-theta",
                    title: "Theta Gate",
                    duration: "45 Min",
                    frequency: "Theta 4–8 Hz",
                    description: "Traumzustand-Einleitung für aktive Regeneration.",
                    streamURL: "https://api.genselfcore.de/v1/signal/deep-sleep-theta",
                    coverColor: "#26274B",
                    dimension: "selbstkenntnis"
                )
            ],
            includedInSub: true
        ),
        SignalProduct(
            id: "burnout-reversal",
            name: "BURNOUT REVERSAL",
            subtitle: "Reset dein Nervensystem",
            tagline: "Alpha-Wellen gegen chronischen Stress",
            audioTracks: [
                AudioTrack(
                    id: "burnout-alpha",
                    title: "Alpha Reset",
                    duration: "30 Min",
                    frequency: "Alpha 8–13 Hz",
                    description: "Entspannung ohne Erschöpfung. Nervensystem regulierung.",
                    streamURL: "https://api.genselfcore.de/v1/signal/burnout-alpha",
                    coverColor: "#4A0E0E",
                    dimension: "verbindung"
                ),
                AudioTrack(
                    id: "burnout-theta",
                    title: "Stress Dissolve",
                    duration: "20 Min",
                    frequency: "Theta 6 Hz",
                    description: "Akute Stressauflösung in 20 Minuten.",
                    streamURL: "https://api.genselfcore.de/v1/signal/burnout-theta",
                    coverColor: "#5C1A1A",
                    dimension: "authentizitaet"
                ),
                AudioTrack(
                    id: "burnout-recovery",
                    title: "Recovery Mode",
                    duration: "45 Min",
                    frequency: "Alpha 10 Hz",
                    description: "Langfristige Erholung für erschöpfte Systeme.",
                    streamURL: "https://api.genselfcore.de/v1/signal/burnout-recovery",
                    coverColor: "#3D1515",
                    dimension: "mut"
                )
            ],
            includedInSub: true
        ),
        SignalProduct(
            id: "hyperfocus",
            name: "HYPERFOCUS FREQUENCY",
            subtitle: "Denke schärfer. Leiste mehr.",
            tagline: "Beta & Gamma für maximale Kognition",
            audioTracks: [
                AudioTrack(
                    id: "hyperfocus-alpha",
                    title: "Flow State",
                    duration: "50 Min",
                    frequency: "Alpha 12 Hz",
                    description: "Erzeuge den Flow-Zustand auf Abruf.",
                    streamURL: "https://api.genselfcore.de/v1/signal/hyperfocus-alpha",
                    coverColor: "#004D40",
                    dimension: "mut"
                ),
                AudioTrack(
                    id: "hyperfocus-beta",
                    title: "Beta Peak",
                    duration: "40 Min",
                    frequency: "Beta 14–30 Hz",
                    description: "Analytisches Denken und logische Verarbeitung maximieren.",
                    streamURL: "https://api.genselfcore.de/v1/signal/hyperfocus-beta",
                    coverColor: "#00695C",
                    dimension: "selbstkenntnis"
                ),
                AudioTrack(
                    id: "hyperfocus-gamma",
                    title: "Gamma Insight",
                    duration: "25 Min",
                    frequency: "Gamma 40 Hz",
                    description: "Spitzenkognition und Kreativität auf höchstem Level.",
                    streamURL: "https://api.genselfcore.de/v1/signal/hyperfocus-gamma",
                    coverColor: "#007A7A",
                    dimension: "klarheit"
                )
            ],
            includedInSub: true
        )
    ]

    static func findTrack(id: String) -> AudioTrack? {
        allProducts.flatMap { $0.audioTracks }.first { $0.id == id }
    }
}
