//
//  DailyChallengeView.swift
//  WordPath
//
//  Created by Jorge Jordán on 3/11/25.
//


import SwiftUI

struct DailyChallengeView: View {
    @ObservedObject var daily = DailyChallengeManager.shared
    @ObservedObject var theme = ThemeManager.shared
    @ObservedObject var economy = EconomyManager.shared

    @StateObject private var vm = GameViewModel() // VM que usaremos para la partida diaria
    @State private var showingGame = false

    var body: some View {
        VStack(spacing: 16) {
            header
            statusCard
            rulesCard
            ctaButtons
            Spacer()
        }
        .padding()
        .background(theme.effectiveTheme.animatedBackground().ignoresSafeArea())
        .navigationTitle("Reto diario")
        .onAppear {
            // refrescar por si cambia de día
            _ = DailyChallengeManager.shared // touch
        }
        // Presentación del juego como fullScreenCover para centrar experiencia
        .fullScreenCover(isPresented: $showingGame) {
            NavigationStack {
                GameView(viewModel: vm, onDailyFinished: {
                    daily.finishDailyRound()
                })
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Salir") { showingGame = false }
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("WORDPATH")
                .font(.title.bold())
                .foregroundStyle(theme.effectiveTheme.textPrimary)
            Text("Reto del \(daily.lastPlayedYMD)")
                .foregroundStyle(theme.effectiveTheme.textSecondary)
        }
    }

    private var statusCard: some View {
        VStack(spacing: 8) {
            HStack {
                Text(daily.completed ? "Estado: Completado" : "Estado: Disponible")
                    .font(.headline)
                Spacer()
            }
            HStack {
                Text("Intentos usados hoy: \(daily.triesUsed)")
                Spacer()
                Text("Gratis/día: \(daily.freeTriesPerDay)")
            }
            .font(.subheadline)
            .foregroundStyle(theme.effectiveTheme.textSecondary)
        }
        .padding()
        .themedBackground(theme.effectiveTheme.cardBackground, cornerRadius: 16)
    }

    private var rulesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cómo funciona")
                .font(.title3.bold())
            Text("• Una palabra de 10 letras fija para todos hoy.")
            Text("• 1 intento gratis por día.")
            Text("• Reintenta pagando \(daily.extraTryCostCoins) coins.")
            Text("• No consume tus intentos normales.")
        }
        .padding()
        .themedBackground(theme.effectiveTheme.cardBackground, cornerRadius: 16)
        .foregroundStyle(theme.effectiveTheme.textPrimary)
    }

    private var ctaButtons: some View {
        VStack(spacing: 10) {
            Button {
                if daily.startDailyRound(using: vm) {
                    vm.isDaily = true
                    vm.onRoundFinished = { _ in
                        DailyChallengeManager.shared.finishDailyRound()
                        vm.onRoundFinished = nil
                    }
                    showingGame = true
                }
            } label: {
                Text(daily.canPlayNow ? "🔥 Jugar reto diario" : "Reto no disponible")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(daily.canPlayNow ? Color.white : Color.gray.opacity(0.4))
                    .foregroundStyle(daily.canPlayNow ? .indigo : .white.opacity(0.6))
                    .clipShape(Capsule())
            }
            .disabled(!daily.canPlayNow)

            if !daily.freeTryAvailable && !daily.completed {
                Text("No te queda intento gratis. Puedes reintentar por \(daily.extraTryCostCoins) coins.")
                    .font(.footnote)
                    .foregroundStyle(theme.effectiveTheme.textSecondary)
            }
        }
        .padding(.top, 8)
    }
}
