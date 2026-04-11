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

    // MARK: - Deep link / Universal Link

    /// Extracts the referral code from the URL and stores it in UserDefaults.
    ///
    /// Supported formats:
    ///   https://genselfcore.de/join?ref=MAX2K4
    ///   selfcore://join?ref=MAX2K4
    private func handleIncomingURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let refItem = components.queryItems?.first(where: { $0.name == "ref" }),
              let code = refItem.value, !code.isEmpty
        else { return }

        let sanitised = code.uppercased().trimmingCharacters(in: .alphanumerics.inverted)
        UserDefaults.standard.set(sanitised, forKey: "pendingReferralCode")
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
                        .environmentObject(appState.referralService)
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
            // ── Universal Link / Deep Link handler ─────────────────────────────
            // Handles both https://genselfcore.de/join?ref=CODE (Associated Domains)
            // and the custom scheme selfcore://join?ref=CODE (Info.plist URL types).
            //
            // When the user opens a referral link BEFORE registering, the code is
            // saved in UserDefaults("pendingReferralCode").  RegisterFormView reads it
            // on appear and pre-fills the referral field automatically.
            .onOpenURL { url in
                handleIncomingURL(url)
            }
        }
    }
}
