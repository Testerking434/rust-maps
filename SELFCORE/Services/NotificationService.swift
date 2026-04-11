// Services/NotificationService.swift
import UserNotifications
import Foundation

class NotificationService {
    static let shared = NotificationService()

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func scheduleDailyNotification(hour: Int, minute: Int) {
        cancelAll()
        let content = UNMutableNotificationContent()
        content.title = "GEN:SELFCORE"
        content.body = dailyMessage()
        content.sound = .default
        content.badge = 1

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-checkin", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // Feature 9: Weekly review notification (Fridays at 18:00)
    func scheduleWeeklyReviewNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Dein Wochenrückblick ist bereit 📊"
        content.body = "Sieh wie weit du diese Woche gekommen bist."
        content.sound = .default
        content.userInfo = ["action": "weekly_review"]

        var components = DateComponents()
        components.weekday = 6  // Friday
        components.hour = 18
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "weekly-review", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // Feature 2: Streak at-risk notification (if no check-in by 20:00)
    func scheduleStreakReminderNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Dein Streak ist in Gefahr 🔥"
        content.body = "Mach heute noch deinen Check-in. Nicht aufhören jetzt."
        content.sound = .default

        var components = DateComponents()
        components.hour = 20
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "streak-reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func cancelStreakReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["streak-reminder"])
    }

    private func dailyMessage() -> String {
        let messages = [
            "Dein SELFCORE-Tag beginnt. Was ist deine Intention?",
            "Wachstum passiert täglich. Starte deinen Check-in.",
            "Du bist nah an deiner besten Version. Mach weiter.",
            "Heute ist ein neuer Schritt auf deinem Weg.",
            "Deine Konstanz macht den Unterschied. Täglicher Check-in.",
            "Was machst du heute anders? Finde es heraus.",
            "Kleine Schritte. Täglich. Das ist die Formel.",
        ]
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return messages[day % messages.count]
    }
}
