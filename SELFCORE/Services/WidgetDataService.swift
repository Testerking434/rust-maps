// Services/WidgetDataService.swift — Feature 4: Widget data sync
import Foundation
import WidgetKit

class WidgetDataService {
    static func update(profile: UserProfile?, streak: StreakData, checkedInToday: Bool) {
        // Use App Group to share data with widget
        let defaults = UserDefaults(suiteName: "group.de.genselfcore.app") ?? .standard

        defaults.set(streak.currentStreak, forKey: "widgetStreak")
        defaults.set(checkedInToday, forKey: "widgetCheckedInToday")

        if let profile = profile {
            defaults.set(profile.selfcoreType.rawValue, forKey: "widgetSelfcoreType")
            defaults.set(profile.selfcoreType.dailyEnergyMode, forKey: "widgetEnergyMode")
            defaults.set(profile.dimensions.weakest.displayName, forKey: "widgetWeakestDimension")

            // Store type color as hex
            switch profile.selfcoreType {
            case .pioneer:   defaults.set("#FF6B35", forKey: "widgetTypeColor")
            case .guardian:  defaults.set("#4A90D9", forKey: "widgetTypeColor")
            case .creator:   defaults.set("#FF6B9D", forKey: "widgetTypeColor")
            case .connector: defaults.set("#5CB85C", forKey: "widgetTypeColor")
            case .achiever:  defaults.set("#F5A623", forKey: "widgetTypeColor")
            }
        }

        // Tell WidgetKit to reload
        WidgetCenter.shared.reloadAllTimelines()
    }
}
