// Views/Signal/AudioRecommendationCard.swift — Feature 7: Audio-Empfehlung
import SwiftUI

struct AudioRecommendationCard: View {
    let profile: UserProfile
    let isSubscribed: Bool
    let onPlay: (AudioTrack) -> Void

    @State private var appear = false

    var weakDim: DimensionType { profile.dimensions.weakest }
    var recommendedTrack: AudioTrack? {
        SignalProduct.findTrack(id: weakDim.recommendedSignalTrackId)
    }

    var body: some View {
        guard let track = recommendedTrack else { return AnyView(EmptyView()) }

        return AnyView(
            VStack(alignment: .leading, spacing: SCSpacing.md) {
                HStack(spacing: 6) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 12))
                        .foregroundColor(.scSignal)
                    Text("EMPFOHLEN FÜR DICH")
                        .font(SCFont.caption(11))
                        .foregroundColor(.scTextSecondary)
                        .tracking(1.5)
                }

                HStack(spacing: SCSpacing.md) {
                    // Track cover
                    ZStack {
                        RoundedRectangle(cornerRadius: SCRadius.md)
                            .fill(
                                LinearGradient(
                                    colors: [track.swiftColor, track.swiftColor.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 64, height: 64)
                        Image(systemName: "waveform")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.8))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(track.title)
                            .font(SCFont.headline(16))
                            .foregroundColor(.white)
                        Text(track.frequency)
                            .font(SCFont.caption(13))
                            .foregroundColor(.scSignal)
                        Text("Stärkt deine \(weakDim.displayName)")
                            .font(SCFont.caption(12))
                            .foregroundColor(.scTextSecondary)
                    }

                    Spacer()
                }

                // Why recommended
                HStack(spacing: 8) {
                    Image(systemName: weakDim.icon)
                        .font(.system(size: 12))
                        .foregroundColor(weakDim.color)
                    Text("Dein Wachstumsfeld: \(weakDim.displayName) (\(String(format: "%.1f", profile.dimensions.value(for: weakDim)))/10)")
                        .font(SCFont.caption(13))
                        .foregroundColor(.scTextSecondary)
                }
                .padding(10)
                .background(weakDim.color.opacity(0.1))
                .cornerRadius(SCRadius.sm)

                // Play button
                Button {
                    onPlay(track)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: isSubscribed ? "play.fill" : "lock.fill")
                            .font(.system(size: 13))
                        Text(isSubscribed ? "Jetzt anhören" : "Freischalten um anzuhören")
                            .font(SCFont.subheadline(14))
                    }
                    .foregroundColor(isSubscribed ? .black : .scSignal)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isSubscribed ? Color.scGold : Color.scSignal.opacity(0.15))
                    .cornerRadius(SCRadius.sm)
                }
            }
            .padding(SCSpacing.md)
            .background(
                ZStack {
                    Color.scCard
                    LinearGradient(
                        colors: [Color.scSignal.opacity(0.06), .clear],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                }
            )
            .cornerRadius(SCRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: SCRadius.lg)
                    .stroke(Color.scSignal.opacity(0.2), lineWidth: 1)
            )
            .offset(y: appear ? 0 : 15)
            .opacity(appear ? 1 : 0)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) { appear = true }
            }
        )
    }
}
