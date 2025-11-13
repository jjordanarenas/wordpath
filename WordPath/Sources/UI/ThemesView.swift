//
//  ThemesView.swift
//  WordPath
//
//  Created by Jorge Jordán on 8/11/25.
//


import SwiftUI

struct ThemesView: View {
    @ObservedObject var theme = ThemeManager.shared
    @ObservedObject var subs = SubscriptionManager.shared
    @ObservedObject var economy = EconomyManager.shared
    @ObservedObject var owned = OwnedThemesStore.shared
    @ObservedObject var stats = StatsManager.shared

    @State private var previewing: ThemeItem?

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                header
                ForEach(ThemeCatalog.all) { item in
                    row(for: item)
                }

                Section {
                    ForEach(ThemeBundles.all) { b in
                        bundleRow(b)
                    }
                }
            }
            .padding()
        }
        .background(theme.effectiveTheme.animatedBackground().ignoresSafeArea())
        .navigationTitle("Temas")
        .sheet(item: $previewing) { item in
            ThemePreviewSheet(item: item)
        }
    }

    private var header: some View {
        HStack {
            Text("Coins: \(economy.coins)")
                .font(.headline)
                .foregroundStyle(theme.effectiveTheme.textPrimary)
            Spacer()
            if subs.isPremium {
                Text("PREMIUM")
                    .font(.caption2.bold())
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(.green.opacity(0.85), in: Capsule())
            }
        }
    }

    private func row(for item: ThemeItem) -> some View {
        // ¿Es el tema actualmente activo?
        let isSelected = (theme.effectiveTheme.id == item.theme.id)
        // ¿Está desbloqueado por ser Premium?
        let premiumUnlocked = (item.lock == .premiumOnly && subs.isPremium)
        // ¿Cumple el requisito de logro (si aplica)?
        let achievementMet: Bool = {
            if case .achievement(_, let required) = item.lock {
                return stats.totalGames >= required
            }
            return true
        }()

        // ¿El usuario ya lo posee o puede aplicarlo?
        let ownedNow = owned.isOwned(item.id) || premiumUnlocked || item.lock == .free || achievementMet

        // Vista principal de la fila
        let rowView = HStack(spacing: 12) {
            Text(item.emoji).font(.title2)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.displayName)
                    .font(.headline)
                    .foregroundStyle(theme.effectiveTheme.textPrimary)

                // Subtítulo según el tipo de lock
                switch item.lock {
                case .free:
                    Text("Gratis")
                        .font(.caption)
                        .foregroundStyle(theme.effectiveTheme.textSecondary)

                case .coins(let price):
                    Text("Disponible por \(price) coins")
                        .font(.caption)
                        .foregroundStyle(theme.effectiveTheme.textSecondary)

                case .premiumOnly:
                    Text("Exclusivo WordPath+")
                        .font(.caption)
                        .foregroundStyle(theme.effectiveTheme.textSecondary)

                case .achievement(let name, let required):
                    let progress = min(stats.totalGames, required)
                    Text("\(name) • \(progress)/\(required)")
                        .font(.caption)
                        .foregroundStyle(achievementMet ? .green : theme.effectiveTheme.textSecondary)
                }
            }

            Spacer()

            Button {
                previewing = item
            } label: {
                Image(systemName: "eye.fill")
            }
            .buttonStyle(.bordered)

            // Acción a la derecha
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.title3)
            } else if ownedNow {
                Button("Aplicar") { apply(item) }
                    .buttonStyle(.borderedProminent)
            } else {
                switch item.lock {
                case .coins(let price):
                    Button("Comprar \(price)") { buy(item, price: price) }
                        .buttonStyle(.borderedProminent)
                        .disabled(economy.coins < price)

                case .premiumOnly:
                    NavigationLink("WordPath+") { SubscriptionView() }
                        .buttonStyle(.borderedProminent)

                case .achievement:
                    // Bloqueado por logro aún no cumplido
                    Label("Bloqueado", systemImage: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                case .free:
                    EmptyView()
                }
            }
        }
        .padding()
        .themedBackground(theme.effectiveTheme.cardBackground, cornerRadius: 16)

        // Atenúa si es logro y aún no está cumplido (sin ser Premium/propiedad)
        if case .achievement = item.lock, !achievementMet, !owned.isOwned(item.id), !premiumUnlocked {
            return AnyView(rowView.opacity(0.65))
        } else {
            return AnyView(rowView)
        }
    }

    private func lockText(_ lock: ThemeItem.Lock) -> String {
        switch lock {
        case .free:
            return "Gratis"

        case .coins(let price):
            return "Disponible por \(price) coins"

        case .premiumOnly:
            return "Exclusivo WordPath+"

        case .achievement(let name, let requiredGames):
            return "\(name) • Requiere \(requiredGames) partidas"
        }
    }

    private func apply(_ item: ThemeItem) {
        theme.setTheme(item.theme)
        Haptics.select(); SFX.blip()
    }

    private func buy(_ item: ThemeItem, price: Int) {
        do {
            try economy.spendCoins(price)
            owned.grant(item.id)
            theme.setTheme(item.theme)
            Haptics.success(); SFX.blip()
        } catch {
            // TODO: Alert de “no tienes coins suficientes”
            print("Buy theme error: \(error.localizedDescription)")
        }
    }

    private func bundleRow(_ b: ThemeBundle) -> some View {
        HStack {
            Text("\(b.emoji) \(b.name)")
                .foregroundStyle(theme.effectiveTheme.textPrimary)

            Spacer()
            Button("Comprar \(b.price)") {
                buyBundle(b)
            }
            .buttonStyle(.borderedProminent)
            .disabled(economy.coins < b.price)
        }
        .padding()
        .themedBackground(theme.effectiveTheme.cardBackground, cornerRadius: 16)
    }

    private func buyBundle(_ b: ThemeBundle) {
        do {
            try economy.spendCoins(b.price)
            b.themes.forEach { owned.grant($0) }
            Haptics.success(); SFX.blip()
        } catch {
            print("Bundle buy error:", error.localizedDescription)
        }
    }
}
