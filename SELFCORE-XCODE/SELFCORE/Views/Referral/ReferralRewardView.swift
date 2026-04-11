// Views/Referral/ReferralRewardView.swift
// Zeigt wenn ein neuer Freund erfolgreich registriert wurde
import SwiftUI

struct ReferralRewardView: View {
    let reward: ReferralReward
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var confettiVisible = true

    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: SCSpacing.lg) {
                // Big reward emoji
                Text(rewardEmoji)
                    .font(.system(size: 80))
                    .scaleEffect(scale)

                // Confetti
                if confettiVisible {
                    ParticlesBurst().frame(height: 80)
                }

                VStack(spacing: SCSpacing.sm) {
                    Text("Dein Freund ist da! 🎉")
                        .font(SCFont.headline(20))
                        .foregroundColor(.scTextSecondary)

                    Text("+\(reward.daysGranted) Tage")
                        .font(SCFont.display(52))
                        .foregroundColor(.scGold)

                    Text("GEN:SIGNAL gratis")
                        .font(SCFont.headline(20))
                        .foregroundColor(.white)

                    Text(reward.description)
                        .font(SCFont.body(14))
                        .foregroundColor(.scTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                // Breakdown
                VStack(spacing: 8) {
                    RewardDetailRow(icon: "person.fill.checkmark", text: "Freund erfolgreich registriert", color: .scSuccess)
                    RewardDetailRow(icon: "waveform", text: "\(reward.daysGranted) Tage GEN:SIGNAL für dich", color: .scSignal)
                    RewardDetailRow(icon: "gift.fill", text: "7 Tage GEN:SIGNAL für deinen Freund", color: .scVerbindung)
                }
                .padding(SCSpacing.md)
                .scCard()

                Button("Weiter wachsen") { onDismiss() }
                    .buttonStyle(SCGoldButtonStyle(fullWidth: false))
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation { confettiVisible = false }
            }
        }
    }

    var rewardEmoji: String {
        switch reward.daysGranted {
        case 1...7:   return "🎁"
        case 8...21:  return "🔥"
        case 22...60: return "⚡️"
        default:       return "👑"
        }
    }
}

struct RewardDetailRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 20)
            Text(text)
                .font(SCFont.body(14))
                .foregroundColor(.white)
            Spacer()
        }
    }
}

// MARK: - Badge Earned View (für Meilensteine)
struct BadgeEarnedView: View {
    let milestone: ReferralMilestone
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var ringScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: SCSpacing.lg) {
                // Pulsing badge
                ZStack {
                    Circle()
                        .stroke(milestone.badgeColor.opacity(0.3), lineWidth: 3)
                        .frame(width: 120 * ringScale, height: 120 * ringScale)
                        .animation(.easeOut(duration: 1.2).repeatForever(autoreverses: false), value: ringScale)

                    ZStack {
                        Circle()
                            .fill(milestone.badgeColor.opacity(0.2))
                            .frame(width: 110, height: 110)
                        Text(milestone.badgeEmoji)
                            .font(.system(size: 60))
                    }
                }

                VStack(spacing: SCSpacing.sm) {
                    Text("Badge freigeschaltet!")
                        .font(SCFont.body(16))
                        .foregroundColor(.scTextSecondary)
                    Text(milestone.badgeTitle)
                        .font(SCFont.display(38))
                        .foregroundColor(milestone.badgeColor)
                    Text("\(milestone.required) Freunde eingeladen")
                        .font(SCFont.subheadline(15))
                        .foregroundColor(.scTextSecondary)
                }

                ParticlesBurst().frame(height: 80)

                VStack(spacing: 6) {
                    Text("Deine Belohnung:")
                        .font(SCFont.caption(13))
                        .foregroundColor(.scTextSecondary)
                    Text(milestone.rewardDescription)
                        .font(SCFont.headline(18))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(SCSpacing.md)
                .background(milestone.badgeColor.opacity(0.1))
                .cornerRadius(SCRadius.md)

                Button("Danke! Weiter") { onDismiss() }
                    .buttonStyle(SCGoldButtonStyle(fullWidth: false))
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
            withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: false)) {
                ringScale = 1.4
            }
        }
    }
}
