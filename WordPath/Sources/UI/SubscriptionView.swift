//
//  SubscriptionView.swift
//  WordPath
//
//  Created by Jorge Jordán on 28/10/25.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @ObservedObject var subs = SubscriptionManager.shared
    @ObservedObject var theme = ThemeManager.shared    // 👈 añadido

    var body: some View {
        VStack(spacing: 16) {
            header

            if subs.products.isEmpty {
                ProgressView("Cargando…")
                    .task { await subs.refresh() }
            } else {
                ForEach(subs.products, id: \.id) { product in
                    productRow(product)
                }
            }

            Button("Restaurar compras") {
                Task { await subs.restore() }
            }
            .buttonStyle(.bordered)

            if let err = subs.lastError {
                Text(err).foregroundStyle(.red).font(.footnote)
            }

            Spacer()
        }
        .padding()
        .background(theme.effectiveTheme.animatedBackground().ignoresSafeArea())  // opcional
        .navigationTitle("WordPath+")
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("Desbloquea WordPath+")
                .font(.title.bold())
                .foregroundStyle(theme.effectiveTheme.textPrimary)
            Text("Partidas ilimitadas, misiones Premium y más opciones de personalización.")
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.effectiveTheme.textSecondary)
        }
    }

    private func productRow(_ product: Product) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(product.displayName).font(.headline)
                    .foregroundStyle(theme.effectiveTheme.textPrimary)
                Text(product.description).font(.caption).foregroundStyle(theme.effectiveTheme.textSecondary)
            }
            Spacer()
            Text(product.displayPrice).font(.headline)
                .foregroundStyle(theme.effectiveTheme.textPrimary)
            Button(subs.purchasing ? "Comprando…" : "Suscribirse") {
                Task { await subs.purchase(product) }
            }
            .buttonStyle(.borderedProminent)
            .disabled(subs.purchasing)
        }
        .padding()
        .themedBackground(theme.effectiveTheme.cardBackground, cornerRadius: 16)   // 👈 aquí
    }
}
