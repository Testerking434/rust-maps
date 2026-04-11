// Services/SubscriptionService.swift — StoreKit 2
import StoreKit
import Foundation
import SwiftUI

@MainActor
class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()

    @Published var products: [Product] = []
    @Published var isSubscribed: Bool = false
    @Published var isLoading: Bool = false
    @Published var purchaseError: String? = nil

    // Product IDs — must match App Store Connect
    let monthlyID = "de.genselfcore.signal.monthly"
    let yearlyID  = "de.genselfcore.signal.yearly"

    private var updateListenerTask: Task<Void, Error>? = nil

    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await checkSubscription()
        }
    }

    deinit { updateListenerTask?.cancel() }

    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: [monthlyID, yearlyID])
            products.sort { $0.id == monthlyID && $1.id == yearlyID }
        } catch {
            print("StoreKit loadProducts error: \(error)")
        }
        isLoading = false
    }

    func checkSubscription() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result {
                if tx.productID == monthlyID || tx.productID == yearlyID {
                    if tx.revocationDate == nil {
                        isSubscribed = true
                        return
                    }
                }
            }
        }
        isSubscribed = false
    }

    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        purchaseError = nil
        defer { isLoading = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let tx) = verification {
                    await tx.finish()
                    await checkSubscription()
                    return true
                }
                return false
            case .userCancelled:
                return false
            case .pending:
                purchaseError = "Kauf wird bearbeitet."
                return false
            @unknown default:
                return false
            }
        } catch {
            purchaseError = "Kauf fehlgeschlagen: \(error.localizedDescription)"
            return false
        }
    }

    func restorePurchases() async {
        isLoading = true
        do {
            try await AppStore.sync()
            await checkSubscription()
        } catch {
            purchaseError = "Wiederherstellen fehlgeschlagen."
        }
        isLoading = false
    }

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let tx) = result {
                    await tx.finish()
                    await self.checkSubscription()
                }
            }
        }
    }

    // Formatted prices
    var monthlyProduct: Product? { products.first { $0.id == monthlyID } }
    var yearlyProduct: Product?  { products.first { $0.id == yearlyID } }

    var monthlySavingsText: String? { nil }
    var yearlySavingsText: String {
        guard let m = monthlyProduct, let y = yearlyProduct else { return "Spare ~42%" }
        let monthlyAnnual = m.price * 12
        guard monthlyAnnual > 0 else { return "Spare ~42%" }
        let saving = (monthlyAnnual - y.price) / monthlyAnnual * 100
        return "Spare \(Int(saving))%"
    }
}
