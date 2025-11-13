//
//  StatisticsView.swift
//  WordPath
//
//  Created by Jorge Jordán on 8/11/25.
//


import SwiftUI

// MARK: - Main

struct StatisticsView: View {
    @ObservedObject var theme = ThemeManager.shared
    @ObservedObject var subs  = SubscriptionManager.shared
    @ObservedObject var stats = StatsManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header

                // Resumen + anillo de win rate
                summarySection

                // Medallero (gratis)
                medalsSection

                // Sección Premium
                premiumSection
            }
            .padding()
        }
        .background(theme.effectiveTheme.background.ignoresSafeArea())
        .navigationTitle("Estadísticas")
    }

    // MARK: Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Tu progreso")
                    .font(.title.bold())
                    .foregroundStyle(theme.effectiveTheme.textPrimary)
                Text("Resumen de tus partidas en WordPath")
                    .font(.subheadline)
                    .foregroundStyle(theme.effectiveTheme.textSecondary)
            }
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

    // MARK: Summary

    private var summarySection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(title: "Partidas", value: "\(stats.totalGames)", theme: theme.effectiveTheme)
                StatCard(title: "Victorias", value: "\(stats.totalWins)", theme: theme.effectiveTheme)
                StatCard(title: "Derrotas", value: "\(stats.totalLosses)", theme: theme.effectiveTheme)
            }

            // Win Rate Ring
            let total = max(1, stats.totalWins + stats.totalLosses)
            let rate  = Double(stats.totalWins) / Double(total)
            HStack {
                ProgressRing(progress: rate,
                             title: "Win Rate",
                             subtitle: "\(Int(rate * 100))%",
                             theme: theme.effectiveTheme)
                .frame(width: 140, height: 140)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Rendimiento")
                        .font(.headline)
                        .foregroundStyle(theme.effectiveTheme.textPrimary)
                    Text("Tu porcentaje de victoria respecto al total de partidas jugadas.")
                        .font(.footnote)
                        .foregroundStyle(theme.effectiveTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            .padding(.top, 6)
        }
    }

    // MARK: Medals

    private var medalsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Medallas")
                .font(.title3.bold())
                .foregroundStyle(theme.effectiveTheme.textPrimary)

            // Tres medallas basadas en las stats actuales
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                MedalBadgeView(
                    emoji: "🏅",
                    title: "Primera Victoria",
                    subtitle: "Gana tu primera partida",
                    unlocked: stats.totalWins >= 1,
                    theme: theme.effectiveTheme
                )

                MedalBadgeView(
                    emoji: "🎯",
                    title: "Calentando",
                    subtitle: "Juega 10 partidas",
                    unlocked: stats.totalGames >= 10,
                    theme: theme.effectiveTheme
                )

                MedalBadgeView(
                    emoji: "🔥",
                    title: "Veterano",
                    subtitle: "Juega 100 partidas",
                    unlocked: stats.totalGames >= 100,
                    theme: theme.effectiveTheme
                )

                MedalBadgeView(
                    emoji: "💪",
                    title: "Dominio",
                    subtitle: "Consigue 25 victorias",
                    unlocked: stats.totalWins >= 25,
                    theme: theme.effectiveTheme
                )
            }
        }
        .padding()
        .themedBackground(theme.effectiveTheme.cardBackground, cornerRadius: 16)
    }

    // MARK: Premium Section

    private var premiumSection: some View {
        Group {
            if subs.isPremium {
                premiumContent
            } else {
                premiumLocked
            }
        }
    }

    private var premiumContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Estadísticas avanzadas")
                .font(.title3.bold())
                .foregroundStyle(theme.effectiveTheme.textPrimary)

            // Bloques “estilo Fitness” con tarjetas y anillos extra.
            HStack(spacing: 12) {
                // Win/Loss ratio bar
                RatioBarCard(
                    wins: stats.totalWins,
                    losses: stats.totalLosses,
                    theme: theme.effectiveTheme
                )

                // Objetivo simple: próxima meta de victorias
                GoalCard(
                    title: "Próxima meta",
                    current: stats.totalWins,
                    target: nextWinTarget(from: stats.totalWins), // 10 → 25 → 50 → 100…
                    unit: "victorias",
                    theme: theme.effectiveTheme
                )
            }

            // Espacio para crecer (cuando añadas más métricas)
            Text("Más analíticas llegarán pronto: rachas, tiempos medios, comparativas por día…")
                .font(.footnote)
                .foregroundStyle(theme.effectiveTheme.textSecondary)
        }
        .padding()
        .themedBackground(theme.effectiveTheme.cardBackground, cornerRadius: 16)
    }

    private func nextWinTarget(from current: Int) -> Int {
        if current < 10 { return 10 }
        if current < 25 { return 25 }
        if current < 50 { return 50 }
        if current < 100 { return 100 }
        if current < 250 { return 250 }
        return current + 100
    }

    private var premiumLocked: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Estadísticas avanzadas")
                        .font(.title3.bold())
                        .foregroundStyle(theme.effectiveTheme.textPrimary)
                    Text("Desbloquea medallas ampliadas, objetivos dinámicos y análisis extra.")
                        .font(.footnote)
                        .foregroundStyle(theme.effectiveTheme.textSecondary)
                }
                Spacer()
            }

            HStack(spacing: 12) {
                PlaceholderLockedCard(title: "Ratio Victorias/Derrotas", theme: theme.effectiveTheme)
                PlaceholderLockedCard(title: "Próxima meta", theme: theme.effectiveTheme)
            }

            NavigationLink {
                SubscriptionView()
            } label: {
                Label("Hazte WordPath+", systemImage: "star.fill")
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(.white, in: Capsule())
                    .foregroundStyle(.indigo)
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
        .themedBackground(theme.effectiveTheme.cardBackground, cornerRadius: 16)
    }
}

// MARK: - Components

struct StatCard: View {
    let title: String
    let value: String
    let theme: WordPathTheme

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(theme.textSecondary)
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(theme.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .themedBackground(theme.cardBackground, cornerRadius: 16)
    }
}

struct ProgressRing: View {
    let progress: Double   // 0...1
    let title: String
    let subtitle: String
    let theme: WordPathTheme

    var body: some View {
        ZStack {
            Circle()
                .stroke(theme.textSecondary.opacity(0.25), lineWidth: 12)
            Circle()
                .trim(from: 0, to: CGFloat(min(max(progress, 0), 1)))
                .stroke(theme.accent, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8), value: progress)
            VStack(spacing: 2) {
                Text(subtitle)
                    .font(.title3.bold())
                    .foregroundStyle(theme.textPrimary)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
            }
        }
        .padding(8)
        .themedBackground(theme.cardBackground, cornerRadius: 16)
    }
}

struct MedalBadgeView: View {
    let emoji: String
    let title: String
    let subtitle: String
    let unlocked: Bool
    let theme: WordPathTheme

    var body: some View {
        HStack(spacing: 12) {
            Text(emoji).font(.title)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(theme.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
            }
            Spacer()
            Image(systemName: unlocked ? "checkmark.seal.fill" : "lock.fill")
                .foregroundStyle(unlocked ? .green : .secondary)
        }
        .padding()
        .themedBackground(theme.cardBackground, cornerRadius: 16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(unlocked ? theme.accent.opacity(0.5) : .white.opacity(0.08), lineWidth: 1)
        )
        .opacity(unlocked ? 1 : 0.9)
    }
}

struct RatioBarCard: View {
    let wins: Int
    let losses: Int
    let theme: WordPathTheme

    var body: some View {
        let total = max(1, wins + losses)
        let winFrac = CGFloat(wins) / CGFloat(total)

        return VStack(alignment: .leading, spacing: 8) {
            Text("Ratio Victorias/Derrotas")
                .font(.headline)
                .foregroundStyle(theme.textPrimary)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.textSecondary.opacity(0.2))
                    .frame(height: 14)

                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.accent)
                    .frame(width: max(8, winFrac * 180), height: 14)
            }

            HStack {
                Text("V: \(wins)")
                Text("D: \(losses)")
                Spacer()
                Text("\(Int(winFrac * 100))%")
                    .bold()
            }
            .font(.caption)
            .foregroundStyle(theme.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .themedBackground(theme.cardBackground, cornerRadius: 16)
    }
}

struct GoalCard: View {
    let title: String
    let current: Int
    let target: Int
    let unit: String
    let theme: WordPathTheme

    var body: some View {
        let prog = Double(min(current, target)) / Double(max(target, 1))
        return VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(theme.textPrimary)

            ProgressView(value: prog)
                .tint(theme.accent)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white.opacity(0.08))
                        .frame(height: 4)
                )

            HStack {
                Text("\(current)/\(target) \(unit)")
                Spacer()
                Text("\(Int(prog * 100))%")
                    .bold()
            }
            .font(.caption)
            .foregroundStyle(theme.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .themedBackground(theme.cardBackground, cornerRadius: 16)
    }
}

struct PlaceholderLockedCard: View {
    let title: String
    let theme: WordPathTheme
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline).foregroundStyle(theme.textPrimary)
            RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(0.08))
                .frame(height: 14)
            HStack {
                Image(systemName: "lock.fill")
                Text("Disponible en WordPath+")
            }
            .font(.caption)
            .foregroundStyle(theme.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .themedBackground(theme.cardBackground, cornerRadius: 16)
    }
}
