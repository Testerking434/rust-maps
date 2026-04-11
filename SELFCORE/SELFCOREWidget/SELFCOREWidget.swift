// SELFCOREWidget/SELFCOREWidget.swift — Feature 4: iOS Home Screen Widget
// WICHTIG: Dieses Widget muss als SEPARATE TARGET in Xcode hinzugefügt werden!
// File > New > Target > Widget Extension > Name: "SELFCOREWidget"

import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct SELFCOREEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let checkedInToday: Bool
    let selfcoreType: String
    let typeColor: String
    let dailyEnergyMode: String
    let dimensionWeakest: String
}

// MARK: - Provider
struct SELFCOREProvider: TimelineProvider {
    func placeholder(in context: Context) -> SELFCOREEntry {
        SELFCOREEntry(
            date: Date(),
            streak: 7,
            checkedInToday: false,
            selfcoreType: "ACHIEVER",
            typeColor: "#F5A623",
            dailyEnergyMode: "ACHIEVE MODE",
            dimensionWeakest: "Mut"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SELFCOREEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SELFCOREEntry>) -> Void) {
        let entry = loadEntry()
        // Refresh every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    func loadEntry() -> SELFCOREEntry {
        let defaults = UserDefaults(suiteName: "group.de.genselfcore.app") ?? .standard

        let streak = defaults.integer(forKey: "widgetStreak")
        let checkedIn = defaults.bool(forKey: "widgetCheckedInToday")
        let type = defaults.string(forKey: "widgetSelfcoreType") ?? "SELFCORE"
        let color = defaults.string(forKey: "widgetTypeColor") ?? "#F5A623"
        let mode = defaults.string(forKey: "widgetEnergyMode") ?? "DEIN TAG"
        let weakest = defaults.string(forKey: "widgetWeakestDimension") ?? "Wachstum"

        return SELFCOREEntry(
            date: Date(),
            streak: streak,
            checkedInToday: checkedIn,
            selfcoreType: type,
            typeColor: color,
            dailyEnergyMode: mode,
            dimensionWeakest: weakest
        )
    }
}

// MARK: - Small Widget View
struct SELFCOREWidgetSmallView: View {
    let entry: SELFCOREEntry

    var body: some View {
        ZStack {
            Color(hex: "#0A0A0A")

            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack {
                    Text("GEN:SELFCORE")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(Color(hex: "#F5A623"))
                    Spacer()
                    Text(entry.checkedInToday ? "✓" : "○")
                        .font(.system(size: 14))
                        .foregroundColor(entry.checkedInToday ? .green : Color(hex: "#888888"))
                }

                Spacer()

                // Energy Mode
                Text(entry.dailyEnergyMode)
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(.white)
                    .lineLimit(2)

                Spacer()

                // Streak
                HStack(spacing: 4) {
                    Text("🔥")
                        .font(.system(size: 14))
                    Text("\(entry.streak)")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(Color(hex: "#F5A623"))
                    Text("Tage")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "#888888"))
                }
            }
            .padding(12)
        }
    }
}

// MARK: - Medium Widget View
struct SELFCOREWidgetMediumView: View {
    let entry: SELFCOREEntry

    var body: some View {
        ZStack {
            Color(hex: "#0A0A0A")

            HStack(spacing: 16) {
                // Left: Streak + type
                VStack(alignment: .leading, spacing: 6) {
                    Text("GEN:SELFCORE")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(Color(hex: "#F5A623"))

                    Text(entry.dailyEnergyMode)
                        .font(.system(size: 15, weight: .black))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    Spacer()

                    HStack(spacing: 4) {
                        Text("🔥")
                        Text("\(entry.streak)")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(Color(hex: "#F5A623"))
                        Text("Tage")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "#888888"))
                    }
                }

                Divider()
                    .background(Color(hex: "#2A2A2A"))

                // Right: Check-in CTA
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(entry.checkedInToday
                                  ? Color.green.opacity(0.2)
                                  : Color(hex: "#F5A623").opacity(0.2))
                            .frame(width: 50, height: 50)
                        Image(systemName: entry.checkedInToday ? "checkmark.circle.fill" : "plus.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(entry.checkedInToday ? .green : Color(hex: "#F5A623"))
                    }
                    Text(entry.checkedInToday ? "Erledigt" : "Check-in")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(entry.checkedInToday ? .green : .white)
                    Text("Wachstumsfeld:\n\(entry.dimensionWeakest)")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "#888888"))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(14)
        }
    }
}

// MARK: - Widget Definition
struct SELFCOREWidget: Widget {
    let kind: String = "SELFCOREWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SELFCOREProvider()) { entry in
            SELFCOREWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("GEN:SELFCORE")
        .description("Dein täglicher Check-in und Streak auf dem Homescreen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct SELFCOREWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: SELFCOREEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SELFCOREWidgetSmallView(entry: entry)
        case .systemMedium:
            SELFCOREWidgetMediumView(entry: entry)
        default:
            SELFCOREWidgetSmallView(entry: entry)
        }
    }
}

// MARK: - Color Extension for Widget
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
