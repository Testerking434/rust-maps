// Views/Settings/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var subscriptionService: SubscriptionService
    @EnvironmentObject var healthKitService: HealthKitService
    @State private var notificationsEnabled = false
    @State private var notificationHour = 8
    @State private var notificationMinute = 0
    @State private var showLogoutAlert = false
    @State private var showPaywall = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.scBackground.ignoresSafeArea()

                List {
                    // Profile section
                    Section {
                        if let profile = appState.profile {
                            HStack(spacing: SCSpacing.md) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [profile.selfcoreType.color, profile.selfcoreType.color.opacity(0.4)],
                                                startPoint: .topLeading, endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 56, height: 56)
                                    Text(profile.firstName.prefix(1).uppercased())
                                        .font(SCFont.display(24))
                                        .foregroundColor(.white)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(profile.name)
                                        .font(SCFont.headline(17))
                                        .foregroundColor(.white)
                                    Text(profile.email)
                                        .font(SCFont.caption(13))
                                        .foregroundColor(.scTextSecondary)
                                    HStack(spacing: 6) {
                                        Image(systemName: profile.selfcoreType.icon)
                                            .font(.system(size: 11))
                                            .foregroundColor(profile.selfcoreType.color)
                                        Text(profile.selfcoreType.displayName)
                                            .font(SCFont.caption(12))
                                            .foregroundColor(profile.selfcoreType.color)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listRowBackground(Color.scCard)

                    // Subscription section
                    Section("GEN:SIGNAL") {
                        if subscriptionService.isSubscribed {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.scSignal)
                                Text("Abo aktiv")
                                    .foregroundColor(.white)
                                Spacer()
                                Text("Premium")
                                    .font(SCFont.caption(12))
                                    .foregroundColor(.scSignal)
                            }
                        } else {
                            Button {
                                showPaywall = true
                            } label: {
                                HStack {
                                    Image(systemName: "waveform")
                                        .foregroundColor(.scGold)
                                    Text("GEN:SIGNAL freischalten")
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("ab 4,99 €/Mo")
                                        .font(SCFont.caption(12))
                                        .foregroundColor(.scGold)
                                }
                            }
                        }

                        Button {
                            Task { await subscriptionService.restorePurchases() }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.scTextSecondary)
                                Text("Käufe wiederherstellen")
                                    .foregroundColor(.scTextSecondary)
                            }
                        }
                    }
                    .listRowBackground(Color.scCard)

                    // Notifications section
                    Section("Benachrichtigungen") {
                        Toggle(isOn: $notificationsEnabled) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.scGold)
                                Text("Tägliche Erinnerung")
                                    .foregroundColor(.white)
                            }
                        }
                        .tint(.scGold)
                        .onChange(of: notificationsEnabled) { enabled in
                            handleNotificationToggle(enabled)
                        }

                        if notificationsEnabled {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.scTextSecondary)
                                DatePicker(
                                    "Uhrzeit",
                                    selection: Binding(
                                        get: {
                                            var c = DateComponents()
                                            c.hour = notificationHour
                                            c.minute = notificationMinute
                                            return Calendar.current.date(from: c) ?? Date()
                                        },
                                        set: { date in
                                            notificationHour = Calendar.current.component(.hour, from: date)
                                            notificationMinute = Calendar.current.component(.minute, from: date)
                                            scheduleNotification()
                                        }
                                    ),
                                    displayedComponents: .hourAndMinute
                                )
                                .foregroundColor(.white)
                            }
                        }
                    }
                    .listRowBackground(Color.scCard)

                    // Feature 10: Apple Health
                    Section("Apple Health") {
                        if healthKitService.isAvailable {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.scError)
                                Text("Mood-Daten synchronisieren")
                                    .foregroundColor(.white)
                                Spacer()
                                if healthKitService.isAuthorized {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.scSuccess)
                                } else {
                                    Button("Verbinden") {
                                        healthKitService.requestAuthorization { _ in }
                                    }
                                    .font(SCFont.caption(13))
                                    .foregroundColor(.scSignal)
                                }
                            }
                            Text("Check-ins und Audio-Sessions werden als Mindful Minutes in Apple Health gespeichert.")
                                .font(SCFont.caption(12))
                                .foregroundColor(.scTextSecondary)
                        } else {
                            HStack {
                                Image(systemName: "heart.slash")
                                    .foregroundColor(.scTextSecondary)
                                Text("Apple Health nicht verfügbar")
                                    .foregroundColor(.scTextSecondary)
                            }
                        }
                    }
                    .listRowBackground(Color.scCard)

                    // Legal section
                    Section("Rechtliches") {
                        NavigationLink {
                            PrivacyPolicyView()
                        } label: {
                            HStack {
                                Image(systemName: "hand.raised.fill")
                                    .foregroundColor(.scTextSecondary)
                                Text("Datenschutzerklärung")
                                    .foregroundColor(.white)
                            }
                        }
                        NavigationLink {
                            ImpressumView()
                        } label: {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(.scTextSecondary)
                                Text("Impressum")
                                    .foregroundColor(.white)
                            }
                        }
                        NavigationLink {
                            NutzungsbedingungenView()
                        } label: {
                            HStack {
                                Image(systemName: "doc.badge.checkmark")
                                    .foregroundColor(.scTextSecondary)
                                Text("Nutzungsbedingungen")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .listRowBackground(Color.scCard)

                    // App info
                    Section("App") {
                        HStack {
                            Text("Version")
                                .foregroundColor(.scTextSecondary)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.scTextSecondary)
                        }
                        HStack {
                            Text("Website")
                                .foregroundColor(.scTextSecondary)
                            Spacer()
                            Text("genselfcore.de")
                                .foregroundColor(.scGold)
                        }
                    }
                    .listRowBackground(Color.scCard)

                    // Logout
                    Section {
                        Button {
                            showLogoutAlert = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Abmelden")
                                    .foregroundColor(.scError)
                                Spacer()
                            }
                        }
                    }
                    .listRowBackground(Color.scCard)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.large)
            .alert("Abmelden?", isPresented: $showLogoutAlert) {
                Button("Abmelden", role: .destructive) { appState.logout() }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text("Du wirst von deinem Konto abgemeldet.")
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView().environmentObject(subscriptionService)
            }
        }
        .onAppear {
            notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
            notificationHour = UserDefaults.standard.integer(forKey: "notificationHour").isMultiple(of: 1) ? UserDefaults.standard.integer(forKey: "notificationHour") : 8
        }
    }

    func handleNotificationToggle(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "notificationsEnabled")
        if enabled {
            NotificationService.shared.requestPermission { granted in
                if granted {
                    scheduleNotification()
                }
            }
        } else {
            NotificationService.shared.cancelAll()
        }
    }

    func scheduleNotification() {
        UserDefaults.standard.set(notificationHour, forKey: "notificationHour")
        UserDefaults.standard.set(notificationMinute, forKey: "notificationMinute")
        NotificationService.shared.scheduleDailyNotification(hour: notificationHour, minute: notificationMinute)
    }
}
