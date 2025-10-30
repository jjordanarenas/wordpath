//
//  SubscriptionManager.swift
//  WordPath
//
//  Created by Jorge Jordán on 27/10/25.
//

import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    private init() {}

    @Published private(set) var isPremium: Bool = false
    @Published private(set) var products: [Product] = []
    @Published var purchasing: Bool = false
    @Published var lastError: String?

    // Ajusta el ID a tu producto en App Store Connect
    private let productIDs = ["wordpath.premium.monthly"]

    func refresh() async {
        await loadProducts()
        await updateEntitlement()
        observeTransactions()
    }

    private func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
                .sorted { $0.price < $1.price }
        } catch {
            lastError = "No se pudieron cargar productos: \(error.localizedDescription)"
        }
    }

    private func updateEntitlement() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let t) = result, productIDs.contains(t.productID) {
                isPremium = true
                return
            }
        }
        isPremium = false
    }

    private func observeTransactions() {
        Task.detached { [weak self] in
            for await update in Transaction.updates {
                guard let self else { continue }
                if case .verified(let transaction) = update {
                    await transaction.finish()
                    if self.productIDs.contains(transaction.productID) {
                        await self.updateEntitlement()
                    }
                }
            }
        }
    }

    func purchase(_ product: Product) async {
        purchasing = true
        defer { purchasing = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let t) = verification {
                    await t.finish()
                    await updateEntitlement()
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            lastError = "Compra fallida: \(error.localizedDescription)"
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
            await updateEntitlement()
        } catch {
            lastError = "Restauración fallida: \(error.localizedDescription)"
        }
    }
}
