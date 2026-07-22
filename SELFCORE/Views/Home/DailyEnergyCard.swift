// Views/Home/DailyEnergyCard.swift — Feature 1: Personalisierte Tagesenergie-Analyse
import SwiftUI

struct DailyEnergyCard: View {
    let profile: UserProfile
    let onSignalTap: () -> Void

    @State private var appear = false

    var body: some View {
        VStack(alignment: .leading, spacing: SCSpacing.md) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.scGold)
                        Text("DEIN HEUTIGER MODUS")
                            .font(SCFont.caption(11))
                            .foregroundColor(.scTextSecondary)
                            .tracking(1.5)
                    }
                    Text(profile.selfcoreType.dailyEnergyMode)
                        .font(SCFont.display(22))
                        .foregroundColor(.white)
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(profile.selfcoreType.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    Image(systemName: profile.selfcoreType.icon)
                        .font(.system(size: 22))
                        .foregroundColor(profile.selfcoreType.color)
                }
            }

            // Description
            Text(profile.selfcoreType.energyDescription)
                .font(SCFont.body(15))
                .foregroundColor(.scTextSecondary)
                .lineSpacing(4)

            // Divider
            Rectangle()
                .fill(Color.scBorder)
                .frame(height: 1)

            // Signal recommendation — Feature 7
            Button(action: onSignalTap) {
                HStack(spacing: 10) {
                    Image(systemName: "waveform")
                        .font(.system(size: 14))
                        .foregroundColor(.scSignal)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Empfohlener Track")
                            .font(SCFont.caption(11))
                            .foregroundColor(.scTextSecondary)
                        Text(recommendedTrackTitle)
                            .font(SCFont.subheadline(14))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.scTextSecondary)
                }
            }
        }
        .padding(SCSpacing.md)
        .scCard()
        .offset(y: appear ? 0 : 20)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) { appear = true }
        }
    }

    var recommendedTrackTitle: String {
        let trackId = profile.selfcoreType.recommendedSignalTrackId
        if let track = SignalProduct.findTrack(id: trackId) {
            return track.title + " · " + track.frequency
        }
        return "GEN:SIGNAL öffnen"
    }
}
