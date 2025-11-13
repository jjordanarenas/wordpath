//
//  HomeView.swift
//  WordPath
//
//  Created by Jorge Jordán on 30/10/25.
//


import SwiftUI

struct HomeView: View {
    @ObservedObject var economy = EconomyManager.shared
    @ObservedObject var subs = SubscriptionManager.shared

    // para animar el logo
    @State private var logoScale: CGFloat = 0.9
    @State private var logoGlow: Bool = false

    // para “continuar partida”
    @State private var hasOngoingGame: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo
                LinearGradient(
                    colors: [.indigo, .purple.opacity(0.85), .black.opacity(0.4)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {

                    // TOP BAR: intentos + coins + premium
                    topBar

                    Spacer(minLength: 12)

                    // LOGO ANIMADO
                    VStack(spacing: 6) {
                        Text("WORDPATH")
                            .font(.system(size: 42, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 4)
                            .scaleEffect(logoScale)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                                    logoScale = 1.0
                                }
                            }

                        Text("Encuentra la palabra. Rápido.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.75))
                    }

                    Spacer()

                    // BOTONES PRINCIPALES
                    VStack(spacing: 14) {
                        NavigationLink {
                            GameView()
                        } label: {
                            Label("Jugar", systemImage: "play.fill")
                                .font(.title2.bold())
                                .padding(.horizontal, 40)
                                .padding(.vertical, 14)
                                .background(.white)
                                .foregroundStyle(.indigo)
                                .clipShape(Capsule())
                                .shadow(radius: 8)
                        }

                        if hasOngoingGame {
                            NavigationLink {
                                GameView() // aquí podrías pasar el estado si lo guardas
                            } label: {
                                Label("Continuar partida", systemImage: "arrow.clockwise")
                                    .font(.body.bold())
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.white.opacity(0.2))
                        }
                    }

                    // SEGUNDA FILA: Economía + Leaderboard
                    HStack(spacing: 14) {
                        NavigationLink {
                            EconomyView()
                        } label: {
                            Label("Economía", systemImage: "bitcoinsign.circle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple.opacity(0.8))

                        Button {
                            Task { @MainActor in
                                GameCenterService.shared.showLeaderboards()
                            }
                        } label: {
                            Label("Leaderboard", systemImage: "trophy.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.yellow.opacity(0.8))
                    }
                    .padding(.horizontal, 4)

                    Spacer()

                    // FILA INFERIOR: Premium + Tutorial + Opciones
                    HStack(spacing: 14) {
                        NavigationLink {
                            SubscriptionView()
                        } label: {
                            Label(subs.isPremium ? "WordPath+ activo" : "WordPath+", systemImage: "star.fill")
                                .padding(.horizontal, 10)
                        }
                        .buttonStyle(.bordered)
                        .tint(subs.isPremium ? .green : .yellow)

                        NavigationLink {
                            TutorialView()
                        } label: {
                            Label("Cómo jugar", systemImage: "questionmark.circle")
                        }
                        .buttonStyle(.bordered)
                        .tint(.white.opacity(0.6))

                        NavigationLink {
                            SettingsView()
                        } label: {
                            Label("Ajustes", systemImage: "gearshape.fill")
                        }
                        .buttonStyle(.bordered)
                        .tint(.white.opacity(0.6))

                        NavigationLink {
                            ThemesView()
                        } label: {
                            Label("Temas", systemImage: "paintpalette.fill")
                        }
                        .buttonStyle(.bordered)
                        .tint(.white.opacity(0.6))

                        NavigationLink {
                            StatisticsView()
                        } label: {
                            Label("Estadísticas", systemImage: "chart.bar.fill")
                        }
                        .buttonStyle(.bordered)
                        .tint(.white.opacity(0.6))

                    }
                    .font(.footnote)
                    .frame(maxWidth: .infinity)

                    Spacer(minLength: 20)
                }
                .padding()
            }
            .task {
                // refrescamos economía y suscripción al entrar
                economy.dailyResetIfNeeded()
                economy.tickRechargeIfNeeded()
                MissionsManager.shared.dailyResetIfNeeded()
                await subs.refresh()
                // aquí decidirás si hay partida en curso; de momento lo dejamos a false
                hasOngoingGame = false
            }
        }
    }

    // MARK: - Top bar
    private var topBar: some View {
        HStack {
            // Intentos
            HStack(spacing: 5) {
                Text("💛 \(economy.attempts)")
                    .font(.headline.monospacedDigit())
                if let remain = economy.timeUntilRecharge(), economy.attempts == 0 {
                    Text("⏳ \(format(remain))")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            Spacer()

            // Coins
            HStack(spacing: 4) {
                Image(systemName: "bitcoinsign.circle.fill")
                Text("\(economy.coins)")
                    .monospacedDigit()
            }
            .font(.headline)
            .foregroundStyle(.white)

            // Premium badge
            if subs.isPremium {
                Text("PREMIUM")
                    .font(.caption2.bold())
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(.green.opacity(0.85), in: Capsule())
            }
        }
        .foregroundStyle(.white)
    }

    private func format(_ seconds: TimeInterval) -> String {
        let s = Int(max(0, seconds))
        let h = s / 3600
        let m = (s % 3600) / 60
        let sec = s % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, sec) : String(format: "%d:%02d", m, sec)
    }
}
