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
        .navigationTitle("WordPath+")
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("Desbloquea WordPath+")
                .font(.title.bold())
            Text("Partidas ilimitadas, misiones Premium y más opciones de personalización.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
    }

    private func productRow(_ product: Product) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(product.displayName).font(.headline)
                Text(product.description).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(product.displayPrice).font(.headline)
            Button(subs.purchasing ? "Comprando…" : "Suscribirse") {
                Task { await subs.purchase(product) }
            }
            .buttonStyle(.borderedProminent)
            .disabled(subs.purchasing)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
