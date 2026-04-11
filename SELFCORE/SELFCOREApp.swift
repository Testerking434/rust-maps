// SELFCOREApp.swift
import SwiftUI
import UserNotifications

@main
struct SELFCOREApp: App {
    @StateObject private var appState = AppState()

    init() {
        // Global navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.scBackground)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        // Tab bar appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(Color.scCard)
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isLoggedIn {
                    MainTabView()
                        .environmentObject(appState)
                        .environmentObject(appState.streakService)
                        .environmentObject(appState.subscriptionService)
                        .environmentObject(appState.healthKitService)
                } else {
                    LoginView()
                        .environmentObject(appState)
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                NotificationService.shared.scheduleWeeklyReviewNotification()
                NotificationService.shared.scheduleStreakReminderNotification()
            }
        }
    }
}
