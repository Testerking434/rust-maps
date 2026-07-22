// Views/Signal/GenSignalView.swift
import SwiftUI

struct GenSignalView: View {
    @EnvironmentObject var subscriptionService: SubscriptionService
    @EnvironmentObject var appState: AppState
    @State private var showPaywall = false
    @State private var showPlayer = false
    @State private var selectedTrack: AudioTrack? = nil
    @ObservedObject var playerManager = AudioPlayerManager.shared

    var body: some View {
        NavigationView {
            ZStack {
                Color.scBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: SCSpacing.md) {
                        // Header
                        signalHeader

                        // Feature 7: Audio Recommendation based on weak dimension
                        if let profile = appState.profile {
                            AudioRecommendationCard(
                                profile: profile,
                                isSubscribed: subscriptionService.isSubscribed
                            ) { track in
                                playTrack(track)
                            }
                        }

                        // Subscription status
                        if subscriptionService.isSubscribed {
                            SubscribedBanner()
                        } else {
                            PaywallTeaser { showPaywall = true }
                        }

                        // Products
                        ForEach(SignalProduct.allProducts) { product in
                            SignalProductCard(
                                product: product,
                                isSubscribed: subscriptionService.isSubscribed,
                                currentTrack: playerManager.currentTrack,
                                onTrackTap: { track in playTrack(track) },
                                onUnlock: { showPaywall = true }
                            )
                        }

                        Color.clear.frame(height: 80)
                    }
                    .padding(.horizontal, SCSpacing.md)
                }

                // Mini player at bottom
                if let track = playerManager.currentTrack {
                    VStack {
                        Spacer()
                        MiniPlayerView(track: track) {
                            selectedTrack = track
                            showPlayer = true
                        }
                        .padding(.horizontal, SCSpacing.md)
                        .padding(.bottom, 90)
                    }
                }
            }
            .navigationTitle("GEN:SIGNAL")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView().environmentObject(subscriptionService)
        }
        .sheet(isPresented: $showPlayer) {
            if let track = selectedTrack {
                FullAudioPlayerView(track: track)
            }
        }
    }

    var signalHeader: some View {
        ZStack {
            RoundedRectangle(cornerRadius: SCRadius.xl)
                .fill(
                    LinearGradient(
                        colors: [Color.scSignalDark, Color.scBackground],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 120)

            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("BINAURAL BEATS")
                        .font(SCFont.caption(11))
                        .foregroundColor(.scSignal.opacity(0.7))
                        .tracking(2)
                    Text("GEN:SIGNAL")
                        .font(SCFont.display(28))
                        .foregroundColor(.white)
                    Text("Ändere dein Gehirn. Verändere dein Leben.")
                        .font(SCFont.body(13))
                        .foregroundColor(.scTextSecondary)
                }
                Spacer()
                LargeWaveformAnimation(color: .scSignal)
                    .frame(width: 80, height: 50)
                    .clipped()
            }
            .padding(SCSpacing.md)
        }
    }

    func playTrack(_ track: AudioTrack) {
        if subscriptionService.isSubscribed {
            playerManager.play(track: track)
            selectedTrack = track
            showPlayer = true
        } else {
            showPaywall = true
        }
    }
}

// MARK: - Signal Product Card
struct SignalProductCard: View {
    let product: SignalProduct
    let isSubscribed: Bool
    let currentTrack: AudioTrack?
    let onTrackTap: (AudioTrack) -> Void
    let onUnlock: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SCSpacing.md) {
            // Product header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(SCFont.headline(16))
                        .foregroundColor(.white)
                    Text(product.tagline)
                        .font(SCFont.body(13))
                        .foregroundColor(.scTextSecondary)
                }
                Spacer()
                if !isSubscribed {
                    Text("PREMIUM")
                        .font(SCFont.caption(10))
                        .foregroundColor(.scGold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.scGold.opacity(0.15))
                        .cornerRadius(8)
                }
            }

            Divider().background(Color.scBorder)

            // Tracks
            VStack(spacing: SCSpacing.xs) {
                ForEach(product.audioTracks) { track in
                    AudioTrackRow(
                        track: track,
                        isSubscribed: isSubscribed,
                        onTap: { onTrackTap(track) }
                    )
                }
            }

            if !isSubscribed {
                Button("Jetzt freischalten") { onUnlock() }
                    .font(SCFont.subheadline(14))
                    .foregroundColor(.scSignal)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.scSignal.opacity(0.1))
                    .cornerRadius(SCRadius.sm)
            }
        }
        .padding(SCSpacing.md)
        .scCard()
    }
}

// MARK: - Subscribed Banner
struct SubscribedBanner: View {
    var body: some View {
        HStack(spacing: SCSpacing.sm) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 22))
                .foregroundColor(.scSignal)
            VStack(alignment: .leading, spacing: 2) {
                Text("GEN:SIGNAL aktiv")
                    .font(SCFont.headline(15))
                    .foregroundColor(.white)
                Text("Alle Tracks freigeschaltet")
                    .font(SCFont.caption(13))
                    .foregroundColor(.scTextSecondary)
            }
            Spacer()
            Image(systemName: "waveform")
                .font(.system(size: 20))
                .foregroundColor(.scSignal.opacity(0.5))
        }
        .padding(SCSpacing.md)
        .background(
            LinearGradient(
                colors: [Color.scSignal.opacity(0.15), Color.scCard],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(SCRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: SCRadius.lg)
                .stroke(Color.scSignal.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Paywall Teaser
struct PaywallTeaser: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: SCSpacing.sm) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Alles freischalten")
                        .font(SCFont.headline(16))
                        .foregroundColor(.white)
                    Text("Ab 4,99 € / Monat · DNA Test = 50 € · Jede Audio = 99 €")
                        .font(SCFont.caption(12))
                        .foregroundColor(.scTextSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.scGold)
            }
            .padding(SCSpacing.md)
            .background(
                LinearGradient(
                    colors: [Color.scGold.opacity(0.15), Color.scCard],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(SCRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: SCRadius.lg)
                    .stroke(Color.scGold.opacity(0.4), lineWidth: 1)
            )
        }
    }
}

// MARK: - Mini Player
struct MiniPlayerView: View {
    let track: AudioTrack
    let onTap: () -> Void
    @ObservedObject var playerManager = AudioPlayerManager.shared

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: SCSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(track.swiftColor.opacity(0.3))
                        .frame(width: 40, height: 40)
                    if playerManager.isPlaying {
                        WaveformIcon()
                    } else {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(SCFont.subheadline(14))
                        .foregroundColor(.white)
                    Text(track.frequency)
                        .font(SCFont.caption(11))
                        .foregroundColor(.scTextSecondary)
                }

                Spacer()

                Button {
                    playerManager.togglePlayPause()
                } label: {
                    Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                }

                Button {
                    playerManager.stop()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                        .foregroundColor(.scTextSecondary)
                        .frame(width: 30, height: 30)
                }
            }
            .padding(SCSpacing.sm)
            .padding(.horizontal, SCSpacing.sm)
            .background(Color.scCardElevated)
            .cornerRadius(SCRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: SCRadius.lg)
                    .stroke(Color.scBorder, lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.4), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
    }
}
