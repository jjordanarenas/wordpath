//
//  SettingsView.swift
//  WordPath
//
//  Created by Jorge Jordán on 30/10/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var theme = ThemeManager.shared
    @ObservedObject var subs  = SubscriptionManager.shared

    private var modeBinding: Binding<ThemeColorMode> {
        Binding(
            get: { theme.mode },
            set: { theme.mode = $0 }
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header

                appearanceCard

                previewCard

                shortcutsCard
            }
            .padding()
        }
        .background(theme.effectiveTheme.animatedBackground().ignoresSafeArea())
        .navigationTitle("Ajustes")
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Personaliza WordPath")
                    .font(.title.bold())
                    .foregroundStyle(theme.effectiveTheme.textPrimary)
                Text("Apariencia, temas y más.")
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

    private var appearanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Apariencia")
                .font(.title3.bold())
                .foregroundStyle(theme.effectiveTheme.textPrimary)

            Picker("Modo de color", selection: modeBinding) {
                Text("Seguir sistema").tag(ThemeColorMode.system)
                Text("Claro").tag(ThemeColorMode.light)
                Text("Oscuro").tag(ThemeColorMode.dark)
            }
            .pickerStyle(.segmented)

            Text(explanation(for: theme.mode))
                .font(.footnote)
                .foregroundStyle(theme.effectiveTheme.textSecondary)
        }
        .padding()
        .themedBackground(theme.effectiveTheme.cardBackground, cornerRadius: 16)
    }

    private func explanation(for mode: ThemeColorMode) -> String {
        switch mode {
        case .system: return "Usa el modo claro u oscuro según el ajuste del dispositivo."
        case .light:  return "Fuerza el modo claro en toda la app."
        case .dark:   return "Fuerza el modo oscuro en toda la app."
        }
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Vista previa del tema")
                .font(.title3.bold())
                .foregroundStyle(theme.effectiveTheme.textPrimary)

            ThemeMiniPreview(theme: theme.effectiveTheme)
                .frame(height: 180)
        }
        .padding()
        .themedBackground(theme.effectiveTheme.cardBackground, cornerRadius: 16)
    }

    private var shortcutsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Accesos directos")
                .font(.title3.bold())
                .foregroundStyle(theme.effectiveTheme.textPrimary)

            HStack(spacing: 12) {
                NavigationLink {
                    ThemesView()
                } label: {
                    Label("Temas", systemImage: "paintpalette.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                NavigationLink {
                    StatisticsView()
                } label: {
                    Label("Estadísticas", systemImage: "chart.bar.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .themedBackground(theme.effectiveTheme.cardBackground, cornerRadius: 16)
    }
}

// Mini preview de 4×4 para ver contraste del tema
struct ThemeMiniPreview: View {
    let theme: WordPathTheme
    let letters = Array("WORDPATHGAMEPLAY".prefix(16))

    var body: some View {
        ZStack {
            theme.background
                .clipShape(RoundedRectangle(cornerRadius: 16))

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(Array(letters.enumerated()), id: \.offset) { i, ch in
                    RoundedRectangle(cornerRadius: 12)
                        .themedBackground(theme.cellBackground, cornerRadius: 12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(i % 5 == 0 ? theme.accent : theme.cellBorder, lineWidth: i % 5 == 0 ? 3 : 1.5)
                        )
                        .overlay(
                            Text(String(ch))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(theme.textPrimary)
                        )
                }
            }
            .padding(12)
        }
    }
}

