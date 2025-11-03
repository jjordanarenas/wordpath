//
//  WordPathTheme.swift
//  WordPath
//
//  Created by Jorge Jordán on 30/10/25.
//

import SwiftUI

struct WordPathTheme: Identifiable, Equatable {
    let id: String
    let name: String

    let background: LinearGradient
    let cardBackground: ThemedBackground     // 👈 debe ser ThemedBackground
    let accent: Color
    let textPrimary: Color
    let textSecondary: Color
    let cellBackground: ThemedBackground     // 👈 igual aquí
    let cellBorder: Color
    let iconSystemName: String

    // 👇 Equatable manual: solo por id
    static func == (lhs: WordPathTheme, rhs: WordPathTheme) -> Bool {
        lhs.id == rhs.id
    }

    static let classic = WordPathTheme(
        id: "classic",
        name: "Clásico",
        background: LinearGradient(colors: [.indigo, .purple.opacity(0.85), .black.opacity(0.4)],
                                   startPoint: .top, endPoint: .bottom),
        cardBackground: .material(.thin),          // 👈 tu enum
        accent: .yellow,
        textPrimary: .white,
        textSecondary: .white.opacity(0.6),
        cellBackground: .material(.ultraThin),     // 👈 tu enum
        cellBorder: .white.opacity(0.4),
        iconSystemName: "sparkles"
    )

    static let neon = WordPathTheme(
        id: "neon",
        name: "Neón",
        background: LinearGradient(colors: [.black, .purple, .pink],
                                   startPoint: .top,
                                   endPoint: .bottom),
        cardBackground: .color(Color.black.opacity(0.5)),  // ✅ usa color
        accent: .green,
        textPrimary: .white,
        textSecondary: .white.opacity(0.5),
        cellBackground: .color(Color.white.opacity(0.05)), // ✅ usa color
        cellBorder: .green,
        iconSystemName: "bolt.fill"
    )

    static func from(id: String) -> WordPathTheme {
        switch id {
        case "neon": return .neon
        default: return .classic
        }
    }
}

