//
//  EconomyView.swift
//  WordPath
//
//  Created by Jorge Jordán on 28/10/25.
//

import SwiftUI

struct EconomyView: View {
    @ObservedObject var economy = EconomyManager.shared
    @ObservedObject var subs = SubscriptionManager.shared
    @ObservedObject var missions = MissionsManager.shared
    @ObservedObject var theme = ThemeManager.shared      // 👈 añadido

    @State private var showAdResult = ""
    let adService: RewardedAdService = AdMobRewardedStub.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                attemptsCard
                coinsCard
                missionsCard
            }
            .padding()
        }
        .background(theme.effectiveTheme.animatedBackground().ignoresSafeArea())  // opcional, para unificar estilo
        .navigationTitle("Economía")
        .onAppear {
            MissionsManager.shared.dailyResetIfNeeded()
            EconomyManager.shared.dailyResetIfNeeded()
            EconomyManager.shared.tickRechargeIfNeeded()
            missions.markProgress(.login)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Intentos: \(economy.attempts)")
                if let remain = economy.timeUntilRecharge(), economy.attempts == 0 {
                    Text("Recarga en \(format(remain))").font(.footnote).foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text("Coins: \(economy.coins)")
        }
        .font(.headline.monospacedDigit())
        .foregroundStyle(theme.effectiveTheme.textPrimary)
    }

    private var attemptsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Intentos")
                .font(.title3.bold())
            Text(subs.isPremium ? "Ilimitados por ser Premium." : "Tienes \(economy.attempts) intentos. Al llegar a 0, se recargan 10 tras 24 horas.")
        }
        .padding()
        .themedBackground(theme.effectiveTheme.cardBackground, cornerRadius: 16)   // 👈 aquí
    }

    private var coinsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Coins")
                .font(.title3.bold())
            Text("Gana coins con misiones diarias. Límite diario: \(subs.isPremium ? EconomyConfig.premiumDailyCoinsCap : EconomyConfig.freeDailyCoinsCap).")
        }
        .padding()
        .themedBackground(theme.effectiveTheme.cardBackground, cornerRadius: 16)
    }

    private var missionsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Misiones diarias")
                .font(.title3.bold())
            ForEach(MissionType.allCases) { t in
                missionRow(type: t)
                Divider().opacity(0.2)
            }
        }
        .padding()
        .themedBackground(theme.effectiveTheme.cardBackground, cornerRadius: 16)
    }

    private func missionRow(type: MissionType) -> some View {
        let m = missions.state.missions[type] ?? Mission(id: type, goal: 1, rewardCoins: 0)
        return HStack {
            VStack(alignment: .leading) {
                Text(title(for: type))
                    .foregroundStyle(theme.effectiveTheme.textPrimary)
                Text("Progreso: \(m.progress)/\(m.goal) · Recompensa: \(m.rewardCoins) 🟡")
                    .font(.caption)
                    .foregroundStyle(theme.effectiveTheme.textSecondary)
            }
            Spacer()
            if missions.canClaim(type) {
                Button("Reclamar") {
                    let res = missions.claim(type, economy: economy, isPremium: subs.isPremium)
                    if case .failure(let e) = res { print("Claim error: \(e.localizedDescription)") }
                }
                .buttonStyle(.borderedProminent)
            } else {
                Image(systemName: m.claimed ? "checkmark.seal.fill" : "seal")
                    .foregroundStyle(m.claimed ? .green : .secondary)
            }
        }
    }

    private func title(for t: MissionType) -> String {
        switch t {
        case .login: return "Inicia sesión hoy"
        case .play1: return "Juega 1 partida"
        case .play3: return "Juega 3 partidas"
        case .useHint: return "Usa una pista"
        case .share: return "Comparte tu resultado"
        }
    }

    private func format(_ seconds: TimeInterval) -> String {
        let s = Int(max(0, seconds))
        let h = s / 3600, m = (s % 3600) / 60, sec = s % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, sec) : String(format: "%d:%02d", m, sec)
    }
}
