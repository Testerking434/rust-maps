// Views/Home/DailyQuoteCard.swift — Feature 6: Tagesquote nach SELFCORE-Typ
import SwiftUI

struct DailyQuoteCard: View {
    let profile: UserProfile
    @State private var appear = false
    @State private var showCopied = false

    var quote: DailyQuote { DailyQuote.todayFor(profile.selfcoreType) }

    var body: some View {
        VStack(alignment: .leading, spacing: SCSpacing.md) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "quote.bubble.fill")
                        .font(.system(size: 12))
                        .foregroundColor(profile.selfcoreType.color)
                    Text("ZITAT DES TAGES")
                        .font(SCFont.caption(11))
                        .foregroundColor(.scTextSecondary)
                        .tracking(1.5)
                }
                Spacer()
                // Type badge
                Text(profile.selfcoreType.rawValue)
                    .font(SCFont.caption(10))
                    .foregroundColor(profile.selfcoreType.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(profile.selfcoreType.color.opacity(0.15))
                    .cornerRadius(10)
            }

            Text("„\(quote.text)"")
                .font(SCFont.subheadline(16))
                .foregroundColor(.white)
                .lineSpacing(5)
                .italic()

            HStack {
                Text("— \(quote.author)")
                    .font(SCFont.caption(13))
                    .foregroundColor(.scTextSecondary)
                Spacer()
                Button(action: copyQuote) {
                    HStack(spacing: 4) {
                        Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 12))
                        Text(showCopied ? "Kopiert" : "Kopieren")
                            .font(SCFont.caption(12))
                    }
                    .foregroundColor(.scTextSecondary)
                }
            }
        }
        .padding(SCSpacing.md)
        .background(
            ZStack {
                Color.scCard
                LinearGradient(
                    colors: [profile.selfcoreType.color.opacity(0.08), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .cornerRadius(SCRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: SCRadius.lg)
                .stroke(profile.selfcoreType.color.opacity(0.2), lineWidth: 1)
        )
        .offset(y: appear ? 0 : 20)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) { appear = true }
        }
    }

    func copyQuote() {
        UIPasteboard.general.string = "„\(quote.text)" — \(quote.author)"
        withAnimation { showCopied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showCopied = false }
        }
    }
}
