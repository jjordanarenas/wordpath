//
//  ThemeCatalog.swift
//  WordPath
//
//  Created by Jorge Jordán on 8/11/25.
//


import SwiftUI

struct ThemeItem: Identifiable, Equatable {
    enum Lock: Equatable {
        case free
        case coins(Int)
        case premiumOnly
        case achievement(name: String, requiredGames: Int)

        static func == (lhs: Lock, rhs: Lock) -> Bool {
            switch (lhs, rhs) {
            case (.free, .free): return true
            case (.premiumOnly, .premiumOnly): return true
            case (.coins(let a), .coins(let b)): return a == b
            case (.achievement(let n1, let r1), .achievement(let n2, let r2)): return n1 == n2 && r1 == r2
            default: return false
            }
        }
    }

    let id: String
    let theme: WordPathTheme
    let lock: Lock
    let displayName: String
    let emoji: String

    // TemaItem Equatable (solo por id)
    static func == (lhs: ThemeItem, rhs: ThemeItem) -> Bool {
        lhs.id == rhs.id
    }
}

enum ThemeCatalog {
    static let all: [ThemeItem] = [
        .init(id: "classic", theme: .classic, lock: .free, displayName: "Clásico", emoji: "✨"),
        .init(id: "neon", theme: .neon, lock: .coins(200), displayName: "Neón", emoji: "⚡️"),
        // Ejemplos para crecer:
        // .init(id: "ocean", theme: .ocean, lock: .coins(200), displayName: "Océano", emoji: "🌊"),
        // .init(id: "navidad", theme: .navidad, lock: .premiumOnly, displayName: "Navidad", emoji: "🎄"),
        .init(id: "halloween", theme: .halloween, lock: .coins(250),
                  displayName: "Halloween", emoji: "🎃"),

            .init(id: "christmas", theme: .christmas, lock: .coins(250),
                  displayName: "Navidad", emoji: "🎄"),

            .init(id: "summer", theme: .summer, lock: .coins(250),
                  displayName: "Verano", emoji: "🌴"),
        .init(
          id: "veteran",
          theme: .veteran,
          lock: .achievement(name: "Juega 100 partidas", requiredGames: 100),
          displayName: "Veterano",
          emoji: "🔥"
        )
    ]

    static func item(for id: String) -> ThemeItem? { all.first { $0.id == id } }
}
