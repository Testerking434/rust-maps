// Views/Referral/ReferralView.swift
import SwiftUI

struct ReferralView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var referralService: ReferralService
    @State private var showShareSheet = false
    @State private var copiedLink = false

    var data: ReferralData { referralService.referralData }

    var body: some View {
        NavigationView {
            ZStack {
                Color.scBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: SCSpacing.lg) {

                        // Hero Banner
                        heroBanner

                        // My Referral Link
                        referralLinkCard

                        // Stats
                        statsRow

                        // Progress to next milestone
                        milestoneProgress

                        // Referred Friends List
                        if !data.referredFriends.isEmpty {
                            friendsList
                        }

                        // How it works
                        howItWorks

                        // All Milestones
                        milestonesOverview

                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, SCSpacing.md)
                }
            }
            .navigationTitle("Freunde einladen")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await referralService.fetchOrCreateCode()
                await referralService.loadReferralData()
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: referralService.shareItems(userName: appState.profile?.firstName ?? ""))
        }
    }

    // MARK: - Hero Banner
    var heroBanner: some View {
        ZStack {
            RoundedRectangle(cornerRadius: SCRadius.xl)
                .fill(
                    LinearGradient(
                        colors: [Color.scGold.opacity(0.3), Color.scVerbindung.opacity(0.2)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: SCSpacing.md) {
                Text("🤝")
                    .font(.system(size: 52))

                VStack(spacing: 6) {
                    Text("Wachse gemeinsam")
                        .font(SCFont.display(26))
                        .foregroundColor(.white)
                    Text("Jeder erfolgreiche Freund = 7 Tage Signal gratis für euch beide")
                        .font(SCFont.body(14))
                        .foregroundColor(.scTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                Button(action: { showShareSheet = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Jetzt einladen")
                    }
                }
                .buttonStyle(SCGoldButtonStyle(fullWidth: false))
            }
            .padding(SCSpacing.xl)
        }
    }

    // MARK: - Referral Link Card
    var referralLinkCard: some View {
        VStack(alignment: .leading, spacing: SCSpacing.md) {
            HStack(spacing: 6) {
                Image(systemName: "link")
                    .font(.system(size: 12))
                    .foregroundColor(.scGold)
                Text("DEIN PERSÖNLICHER LINK")
                    .font(SCFont.caption(11))
                    .foregroundColor(.scTextSecondary)
                    .tracking(1.5)
            }

            if referralService.isLoading || data.referralCode.isEmpty {
                RoundedRectangle(cornerRadius: SCRadius.sm)
                    .fill(Color.scCardElevated)
                    .frame(height: 48)
                    .shimmer()
            } else {
                HStack(spacing: SCSpacing.sm) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(data.referralLink)
                            .font(SCFont.mono(13))
                            .foregroundColor(.scSignal)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Text("Code: \(data.referralCode)")
                            .font(SCFont.mono(11))
                            .foregroundColor(.scTextSecondary)
                    }
                    Spacer()
                    Button {
                        UIPasteboard.general.string = data.referralLink
                        withAnimation { copiedLink = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { copiedLink = false }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: copiedLink ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 13))
                            Text(copiedLink ? "Kopiert!" : "Kopieren")
                                .font(SCFont.caption(13))
                        }
                        .foregroundColor(copiedLink ? .scSuccess : .scGold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(copiedLink ? Color.scSuccess.opacity(0.1) : Color.scGold.opacity(0.1))
                        .cornerRadius(SCRadius.sm)
                    }
                }
                .padding(SCSpacing.md)
                .background(Color.scCardElevated)
                .cornerRadius(SCRadius.md)
            }

            // Share options
            HStack(spacing: SCSpacing.sm) {
                ShareOptionButton(icon: "message.fill", label: "WhatsApp", color: Color(hex: "#25D366")) {
                    shareViaWhatsApp()
                }
                ShareOptionButton(icon: "link", label: "Link kopieren", color: .scGold) {
                    UIPasteboard.general.string = data.referralLink
                    withAnimation { copiedLink = true }
                }
                ShareOptionButton(icon: "square.and.arrow.up", label: "Mehr", color: .scSignal) {
                    showShareSheet = true
                }
            }
        }
        .padding(SCSpacing.md)
        .scCard()
    }

    // MARK: - Stats Row
    var statsRow: some View {
        HStack(spacing: SCSpacing.sm) {
            ReferralStatBubble(
                value: "\(data.totalReferred)",
                label: "Freunde\ngewonnen",
                icon: "person.2.fill",
                color: .scVerbindung
            )
            ReferralStatBubble(
                value: "+\(totalEarnedDays)",
                label: "Tage Signal\ngratis",
                icon: "waveform",
                color: .scSignal
            )
            ReferralStatBubble(
                value: currentBadgeName,
                label: "Aktueller\nStatus",
                icon: "star.fill",
                color: .scGold
            )
        }
    }

    var totalEarnedDays: Int { data.totalReferred * 7 }

    var currentBadgeName: String {
        referralService.currentBadge?.badgeTitle ?? "—"
    }

    // MARK: - Milestone Progress
    var milestoneProgress: some View {
        VStack(alignment: .leading, spacing: SCSpacing.md) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.scGold)
                    Text("NÄCHSTER MEILENSTEIN")
                        .font(SCFont.caption(11))
                        .foregroundColor(.scTextSecondary)
                        .tracking(1.5)
                }
                Spacer()
            }

            if let next = data.nextMilestone {
                HStack(spacing: SCSpacing.md) {
                    Text(next.badgeEmoji)
                        .font(.system(size: 36))

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(next.badgeTitle)
                                .font(SCFont.headline(17))
                                .foregroundColor(next.badgeColor)
                            Spacer()
                            Text("\(data.totalReferred)/\(next.required) Freunde")
                                .font(SCFont.mono(13))
                                .foregroundColor(.scTextSecondary)
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.scBorder).frame(height: 8)
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [next.badgeColor, next.badgeColor.opacity(0.6)],
                                            startPoint: .leading, endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * data.progressToNext, height: 8)
                                    .animation(.easeInOut(duration: 0.8), value: data.progressToNext)
                            }
                        }
                        .frame(height: 8)

                        Text("Belohnung: \(next.rewardDescription)")
                            .font(SCFont.caption(12))
                            .foregroundColor(.scTextSecondary)
                    }
                }
            } else {
                HStack(spacing: 12) {
                    Text("👑")
                        .font(.system(size: 36))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("LEGEND")
                            .font(SCFont.headline(17))
                            .foregroundColor(.scGold)
                        Text("Du hast alle Meilensteine erreicht. Außergewöhnlich.")
                            .font(SCFont.caption(13))
                            .foregroundColor(.scTextSecondary)
                    }
                }
            }
        }
        .padding(SCSpacing.md)
        .scCard()
    }

    // MARK: - Friends List
    var friendsList: some View {
        VStack(alignment: .leading, spacing: SCSpacing.md) {
            HStack(spacing: 6) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.scVerbindung)
                Text("DEINE FREUNDE (\(data.totalReferred))")
                    .font(SCFont.caption(11))
                    .foregroundColor(.scTextSecondary)
                    .tracking(1.5)
            }

            ForEach(data.referredFriends) { friend in
                HStack(spacing: SCSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(friend.avatarSwiftColor.opacity(0.3))
                            .frame(width: 40, height: 40)
                        Text(friend.firstName.prefix(1).uppercased())
                            .font(SCFont.headline(16))
                            .foregroundColor(friend.avatarSwiftColor)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(friend.firstName)
                            .font(SCFont.subheadline(15))
                            .foregroundColor(.white)
                        Text("Beigetreten: \(friend.formattedDate)")
                            .font(SCFont.caption(12))
                            .foregroundColor(.scTextSecondary)
                    }

                    Spacer()

                    if friend.isActive {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.scSuccess)
                                .frame(width: 6, height: 6)
                            Text("+7 Tage")
                                .font(SCFont.caption(12))
                                .foregroundColor(.scSuccess)
                        }
                    } else {
                        Text("Ausstehend")
                            .font(SCFont.caption(11))
                            .foregroundColor(.scTextSecondary)
                    }
                }
            }
        }
        .padding(SCSpacing.md)
        .scCard()
    }

    // MARK: - How It Works
    var howItWorks: some View {
        VStack(alignment: .leading, spacing: SCSpacing.md) {
            Text("WIE ES FUNKTIONIERT")
                .font(SCFont.caption(11))
                .foregroundColor(.scTextSecondary)
                .tracking(1.5)

            VStack(spacing: SCSpacing.sm) {
                HowItWorksStep(step: 1, icon: "square.and.arrow.up", text: "Teile deinen persönlichen Link mit Freunden", color: .scGold)
                HowItWorksStep(step: 2, icon: "person.crop.circle.badge.plus", text: "Freund erstellt seinen Account über deinen Link", color: .scVerbindung)
                HowItWorksStep(step: 3, icon: "gift.fill", text: "Ihr beide bekommt 7 Tage GEN:SIGNAL gratis", color: .scSignal)
                HowItWorksStep(step: 4, icon: "trophy.fill", text: "Je mehr Freunde, desto höher dein Badge & mehr Tage", color: .scMut)
            }
        }
        .padding(SCSpacing.md)
        .scCard()
    }

    // MARK: - Milestones Overview
    var milestonesOverview: some View {
        VStack(alignment: .leading, spacing: SCSpacing.md) {
            Text("ALLE MEILENSTEINE")
                .font(SCFont.caption(11))
                .foregroundColor(.scTextSecondary)
                .tracking(1.5)

            ForEach(ReferralMilestone.all, id: \.required) { milestone in
                let reached = data.totalReferred >= milestone.required
                HStack(spacing: SCSpacing.md) {
                    Text(milestone.badgeEmoji)
                        .font(.system(size: 28))
                        .opacity(reached ? 1 : 0.4)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(milestone.badgeTitle)
                                .font(SCFont.subheadline(15))
                                .foregroundColor(reached ? milestone.badgeColor : .scTextSecondary)
                            Text("\(milestone.required) Freunde")
                                .font(SCFont.caption(12))
                                .foregroundColor(.scTextSecondary)
                        }
                        Text(milestone.rewardDescription)
                            .font(SCFont.caption(12))
                            .foregroundColor(reached ? .white : .scTextSecondary.opacity(0.6))
                    }

                    Spacer()

                    if reached {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 20))
                            .foregroundColor(milestone.badgeColor)
                    }
                }
                .padding(SCSpacing.sm)
                .background(reached ? milestone.badgeColor.opacity(0.08) : Color.clear)
                .cornerRadius(SCRadius.sm)
            }
        }
        .padding(SCSpacing.md)
        .scCard()
    }

    // MARK: - Share Actions
    func shareViaWhatsApp() {
        let text = referralService.shareItems(userName: appState.profile?.firstName ?? "").first as? String ?? ""
        let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "whatsapp://send?text=\(encoded)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showShareSheet = true
        }
    }
}

// MARK: - Supporting Views
struct ShareOptionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }
                Text(label)
                    .font(SCFont.caption(11))
                    .foregroundColor(.scTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct ReferralStatBubble: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            Text(value)
                .font(SCFont.display(20))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(SCFont.caption(10))
                .foregroundColor(.scTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, SCSpacing.md)
        .scCard()
    }
}

struct HowItWorksStep: View {
    let step: Int
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: SCSpacing.md) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            Text(text)
                .font(SCFont.body(14))
                .foregroundColor(.white)
                .lineSpacing(3)
            Spacer()
        }
    }
}

// MARK: - iOS Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
