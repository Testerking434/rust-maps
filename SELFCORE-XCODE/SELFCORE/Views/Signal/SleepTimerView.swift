// Views/Signal/SleepTimerView.swift — Feature 5: Sleep Timer
import SwiftUI

struct SleepTimerView: View {
    @ObservedObject var playerManager: AudioPlayerManager
    @Environment(\.dismiss) var dismiss

    let presets = [15, 20, 30, 45, 60, 90]

    var body: some View {
        ZStack {
            Color.scBackground.ignoresSafeArea()

            VStack(spacing: SCSpacing.lg) {
                // Handle
                Capsule()
                    .fill(Color.scBorder)
                    .frame(width: 40, height: 4)
                    .padding(.top)

                // Header
                VStack(spacing: 8) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.scSignal)
                    Text("Sleep Timer")
                        .font(SCFont.headline(22))
                        .foregroundColor(.white)
                    Text("Musik stoppt automatisch nach der gewählten Zeit.")
                        .font(SCFont.body(14))
                        .foregroundColor(.scTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                // Current timer status
                if playerManager.sleepTimerActive {
                    VStack(spacing: 6) {
                        Text(playerManager.sleepTimerDisplay)
                            .font(SCFont.display(48))
                            .foregroundColor(.scSignal)
                        Text("verbleibend")
                            .font(SCFont.body(14))
                            .foregroundColor(.scTextSecondary)
                        Button("Timer abbrechen") {
                            playerManager.cancelSleepTimer()
                            dismiss()
                        }
                        .font(SCFont.subheadline(15))
                        .foregroundColor(.scError)
                        .padding(.top, 4)
                    }
                    .padding(SCSpacing.md)
                    .scCard()
                    .padding(.horizontal, SCSpacing.lg)
                }

                // Presets
                VStack(alignment: .leading, spacing: SCSpacing.sm) {
                    Text("TIMER WÄHLEN")
                        .font(SCFont.caption(11))
                        .foregroundColor(.scTextSecondary)
                        .tracking(1.5)
                        .padding(.horizontal, SCSpacing.lg)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: SCSpacing.sm) {
                        ForEach(presets, id: \.self) { minutes in
                            Button {
                                playerManager.setSleepTimer(minutes: minutes)
                                dismiss()
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "moon.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(playerManager.sleepTimerMinutes == minutes && playerManager.sleepTimerActive ? .scSignal : .scTextSecondary)
                                    Text("\(minutes) Min")
                                        .font(SCFont.subheadline(14))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, SCSpacing.md)
                                .background(
                                    playerManager.sleepTimerMinutes == minutes && playerManager.sleepTimerActive
                                        ? Color.scSignal.opacity(0.15)
                                        : Color.scCard
                                )
                                .cornerRadius(SCRadius.md)
                                .overlay(
                                    RoundedRectangle(cornerRadius: SCRadius.md)
                                        .stroke(
                                            playerManager.sleepTimerMinutes == minutes && playerManager.sleepTimerActive
                                                ? Color.scSignal
                                                : Color.clear,
                                            lineWidth: 1.5
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal, SCSpacing.lg)
                }

                // End of playlist
                Button {
                    playerManager.sleepTimerMinutes = 0
                    playerManager.cancelSleepTimer()
                    dismiss()
                } label: {
                    Text("Kein Timer")
                        .font(SCFont.subheadline(15))
                        .foregroundColor(.scTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.scCard)
                        .cornerRadius(SCRadius.md)
                }
                .padding(.horizontal, SCSpacing.lg)

                Spacer()
            }
        }
        .presentationDetents([.medium, .large])
    }
}
