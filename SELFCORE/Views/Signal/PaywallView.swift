// Views/Signal/PaywallView.swift — Subscription Paywall
import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var subscriptionService: SubscriptionService
    @Environment(\.dismiss) var dismiss
    @State private var selectedProduct: String? = nil
    @State private var showError = false

    var body: some View {
        ZStack {
            Color.scBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: SCSpacing.lg) {
                    // Header
                    VStack(spacing: SCSpacing.md) {
                        Image(systemName: "waveform.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.scSignal)
                            .padding(.top, SCSpacing.xl)

                        Text("GEN:SIGNAL")
                            .font(SCFont.display(32))
                            .foregroundColor(.white)

                        Text("Binaural Beats für dein SELFCORE-Wachstum")
                            .font(SCFont.body(16))
                            .foregroundColor(.scTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }

                    // Value comparison
                    VStack(spacing: SCSpacing.sm) {
                        Text("WAS DU BEKOMMST")
                            .font(SCFont.caption(11))
                            .foregroundColor(.scTextSecondary)
                            .tracking(1.5)

                        VStack(spacing: SCSpacing.sm) {
                            FeatureRow(icon: "waveform", text: "8 binaural Tracks (Wert: 8 × 99 € = 792 €)", highlight: true)
                            FeatureRow(icon: "moon.stars.fill", text: "Deep Sleep Protocol — Schlafe wie nie zuvor")
                            FeatureRow(icon: "bolt.fill", text: "HyperFocus Frequency — Denke schärfer")
                            FeatureRow(icon: "heart.fill", text: "Burnout Reversal — Reset dein Nervensystem")
                            FeatureRow(icon: "iphone", text: "Hintergrundwiedergabe — auch bei gesperrtem Bildschirm")
                            FeatureRow(icon: "moon.zzz.fill", text: "Sleep Timer — automatisch einschlafen")
                            FeatureRow(icon: "apple.logo", text: "Apple Health Integration — Mindful Minutes")
                            FeatureRow(icon: "star.fill", text: "Neue Tracks werden automatisch freigeschaltet")
                        }
                        .padding(SCSpacing.md)
                        .scCard()
                    }

                    // Pricing
                    VStack(spacing: SCSpacing.sm) {
                        if subscriptionService.isLoading {
                            ProgressView().tint(.scGold)
                        } else if subscriptionService.products.isEmpty {
                            // Fallback for simulator
                            SubscriptionOptionFallback(
                                title: "Monatlich",
                                price: "4,99 € / Monat",
                                badge: nil,
                                isSelected: selectedProduct == "monthly"
                            ) { selectedProduct = "monthly" }

                            SubscriptionOptionFallback(
                                title: "Jährlich",
                                price: "34,99 € / Jahr",
                                badge: "Spare 41%",
                                isSelected: selectedProduct == "yearly"
                            ) { selectedProduct = "yearly" }
                        } else {
                            ForEach(subscriptionService.products) { product in
                                SubscriptionOptionCard(
                                    product: product,
                                    isYearly: product.id == subscriptionService.yearlyID,
                                    savingsText: product.id == subscriptionService.yearlyID ? subscriptionService.yearlySavingsText : nil,
                                    isSelected: selectedProduct == product.id,
                                    onSelect: { selectedProduct = product.id }
                                )
                            }
                        }
                    }

                    // CTA
                    Button {
                        Task {
                            if let id = selectedProduct,
                               let product = subscriptionService.products.first(where: { $0.id == id }) {
                                let success = await subscriptionService.purchase(product)
                                if success { dismiss() }
                            } else if !subscriptionService.products.isEmpty {
                                // Select first
                                selectedProduct = subscriptionService.products.first?.id
                            }
                        }
                    } label: {
                        HStack {
                            if subscriptionService.isLoading {
                                ProgressView().tint(.black)
                            } else {
                                Text("Jetzt freischalten")
                            }
                        }
                    }
                    .buttonStyle(SCGoldButtonStyle())
                    .padding(.horizontal, SCSpacing.lg)
                    .disabled(subscriptionService.isLoading)

                    if let err = subscriptionService.purchaseError {
                        Text(err)
                            .font(SCFont.caption(13))
                            .foregroundColor(.scError)
                            .multilineTextAlignment(.center)
                    }

                    // Restore + Legal
                    VStack(spacing: SCSpacing.sm) {
                        Button("Käufe wiederherstellen") {
                            Task { await subscriptionService.restorePurchases() }
                        }
                        .font(SCFont.caption(14))
                        .foregroundColor(.scTextSecondary)

                        Text("Abo wird automatisch verlängert. Kündigung jederzeit in den App-Einstellungen möglich. Zahlung erfolgt über deinen Apple ID Account.")
                            .font(SCFont.caption(11))
                            .foregroundColor(.scTextSecondary.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }

                    Color.clear.frame(height: 30)
                }
                .padding(.horizontal, SCSpacing.md)
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    var highlight: Bool = false

    var body: some View {
        HStack(spacing: SCSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(highlight ? .scGold : .scSignal)
                .frame(width: 20)
            Text(text)
                .font(SCFont.body(14))
                .foregroundColor(highlight ? .scGold : .white)
            Spacer()
        }
    }
}

struct SubscriptionOptionCard: View {
    let product: Product
    let isYearly: Bool
    let savingsText: String?
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(isYearly ? "Jährlich" : "Monatlich")
                            .font(SCFont.headline(16))
                            .foregroundColor(.white)
                        if let savings = savingsText {
                            Text(savings)
                                .font(SCFont.caption(11))
                                .foregroundColor(.scGold)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(Color.scGold.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    if isYearly {
                        Text(String(format: "%.2f € / Monat", (product.price / 12) as NSDecimalNumber))
                            .font(SCFont.caption(12))
                            .foregroundColor(.scTextSecondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(SCFont.headline(18))
                        .foregroundColor(.scGold)
                    Text(isYearly ? "/ Jahr" : "/ Monat")
                        .font(SCFont.caption(11))
                        .foregroundColor(.scTextSecondary)
                }
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .scGold : .scBorder)
                    .padding(.leading, 8)
            }
            .padding(SCSpacing.md)
            .background(isSelected ? Color.scGold.opacity(0.08) : Color.scCard)
            .cornerRadius(SCRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: SCRadius.md)
                    .stroke(isSelected ? Color.scGold : Color.scBorder, lineWidth: isSelected ? 1.5 : 0.5)
            )
        }
    }
}

struct SubscriptionOptionFallback: View {
    let title: String
    let price: String
    let badge: String?
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title).font(SCFont.headline(16)).foregroundColor(.white)
                        if let badge = badge {
                            Text(badge)
                                .font(SCFont.caption(11))
                                .foregroundColor(.scGold)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(Color.scGold.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
                Spacer()
                Text(price).font(SCFont.headline(15)).foregroundColor(.scGold)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .scGold : .scBorder)
                    .padding(.leading, 8)
            }
            .padding(SCSpacing.md)
            .background(isSelected ? Color.scGold.opacity(0.08) : Color.scCard)
            .cornerRadius(SCRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: SCRadius.md)
                    .stroke(isSelected ? Color.scGold : Color.scBorder, lineWidth: isSelected ? 1.5 : 0.5)
            )
        }
    }
}
