//
//  EndOfRoundBanner.swift
//  WordPath
//
//  Created by Jorge Jordán on 28/10/25.
//


import SwiftUI

struct EndOfRoundBanner: View {
    let win: Bool
    let score: Int
    let targetWord: String
    let onPlayAgain: () -> Void
    let onLeaderboard: () -> Void
    let onShare: () -> Void

    var body: some View {
        ZStack {
            // Fondo oscurecido
            Color.black.opacity(0.55).ignoresSafeArea()

            VStack(spacing: 12) {
                Text(win ? "¡Bien hecho!" : "¡Buen intento!")
                    .font(.title2.bold())

                Text(win ? "Puntuación: \(score)" : "La palabra era: \(targetWord)")
                    .font(.headline)

                HStack(spacing: 10) {
                    Button("Jugar de nuevo", action: onPlayAgain)
                        .buttonStyle(.borderedProminent)

                    Button("Leaderboard", action: onLeaderboard)
                        .buttonStyle(.bordered)
                }

                Button("Compartir resultado", action: onShare)
                    .buttonStyle(.bordered)

            }
            .padding(20)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 24)
        }
        .transition(.opacity.combined(with: .scale))
    }
}
