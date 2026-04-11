// Views/MainTabView.swift
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var streakService: StreakService
    @EnvironmentObject var referralService: ReferralService
    @State private var selectedTab: Int = 0

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)

                ProfileView()
                    .tabItem {
                        Label("Profil", systemImage: "person.fill")
                    }
                    .tag(1)

                CoursesView()
                    .tabItem {
                        Label("Kurse", systemImage: "book.fill")
                    }
                    .tag(2)

                GenSignalView()
                    .tabItem {
                        Label("Signal", systemImage: "headphones")
                    }
                    .tag(3)

                HistoryView()
                    .tabItem {
                        Label("Verlauf", systemImage: "chart.bar.fill")
                    }
                    .tag(4)

                // Referral Tab mit Badge wenn Rewards ausstehen
                ReferralView()
                    .tabItem {
                        Label("Einladen", systemImage: "person.badge.plus")
                    }
                    .tag(5)
                    .badge(appState.referralBadgeCount > 0 ? appState.referralBadgeCount : 0)

                SettingsView()
                    .tabItem {
                        Label("Einstellungen", systemImage: "gearshape.fill")
                    }
                    .tag(6)
            }
            .tint(.scGold)

            // Feature 2: Milestone Celebration overlay
            if streakService.showMilestoneCelebration {
                MilestoneCelebrationView(
                    streak: streakService.celebratedMilestone,
                    title: streakService.data.milestoneTitle
                ) {
                    streakService.dismissCelebration()
                }
                .transition(.opacity)
                .zIndex(100)
            }

            // Referral Reward overlay — wenn Freund erfolgreich registriert
            if referralService.showNewReward, let reward = referralService.latestReward {
                ReferralRewardView(reward: reward) {
                    referralService.dismissNewReward()
                }
                .transition(.opacity)
                .zIndex(200)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: streakService.showMilestoneCelebration)
        .animation(.easeInOut(duration: 0.3), value: referralService.showNewReward)
    }
}

// MARK: - Feature 2: Milestone Celebration
struct MilestoneCelebrationView: View {
    let streak: Int
    let title: String
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: SCSpacing.lg) {
                // Confetti emoji burst
                Text(streakEmoji)
                    .font(.system(size: 80))
                    .scaleEffect(scale)

                VStack(spacing: SCSpacing.sm) {
                    Text("\(streak) TAGE")
                        .font(SCFont.display(48))
                        .foregroundColor(.scGold)
                    Text(title)
                        .font(SCFont.headline(20))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("Du bist unaufhaltbar.")
                        .font(SCFont.body(16))
                        .foregroundColor(.scTextSecondary)
                }

                ParticlesBurst()
                    .frame(height: 100)

                Button("Weiter wachsen") { onDismiss() }
                    .buttonStyle(SCGoldButtonStyle(fullWidth: false))
                    .padding(.top, SCSpacing.md)
            }
            .padding(SCSpacing.xl)
            .scCard(elevated: true)
            .padding(.horizontal, SCSpacing.lg)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }

    var streakEmoji: String {
        switch streak {
        case 3:   return "🌱"
        case 7:   return "🔥"
        case 14:  return "⚡️"
        case 21:  return "💎"
        case 30:  return "🏆"
        case 60:  return "👑"
        case 100: return "🌟"
        default:  return "🎯"
        }
    }
}

// MARK: - Particles Burst Animation (Feature 2 + 8)
struct ParticlesBurst: View {
    @State private var animate = false
    let particles: [(CGFloat, CGFloat, Color)] = [
        (-60, -40, .scGold), (60, -40, .scSignal), (0, -70, .scAuthentizitaet),
        (-80, 20, .scVerbindung), (80, 20, .scMut), (-30, 60, .scGold),
        (30, 60, .scKlarheit), (-100, -10, .scSignal), (100, -10, .scSelbstkenntnis)
    ]

    var body: some View {
        ZStack {
            ForEach(0..<particles.count, id: \.self) { i in
                let (x, y, color) = particles[i]
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .offset(x: animate ? x : 0, y: animate ? y : 0)
                    .opacity(animate ? 0 : 1)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) { animate = true }
        }
    }
}
