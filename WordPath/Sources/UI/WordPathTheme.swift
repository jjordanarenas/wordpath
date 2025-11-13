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

    // 👇 ahora guardamos la paleta y generamos el gradient
    let backgroundColors: [Color]
    var background: LinearGradient {
        LinearGradient(colors: backgroundColors, startPoint: .top, endPoint: .bottom)
    }
    let cardBackground: ThemedBackground     // 👈 debe ser ThemedBackground
    let accent: Color
    let textPrimary: Color
    let textSecondary: Color
    let cellBackground: ThemedBackground     // 👈 igual aquí
    let cellBorder: Color
    let iconSystemName: String
    var animated: Bool = false

    /// 👇 Solo guardamos el ID del tema oscuro (si existe) para evitar recursividad
    let darkVariantID: String?    // 👇 Equatable manual: solo por id

    static func == (lhs: WordPathTheme, rhs: WordPathTheme) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: Classic
    static let classicDark = WordPathTheme(
        id: "classic.dark",
        name: "Clásico (Oscuro)",
        backgroundColors: [.black, .indigo.opacity(0.55), .purple.opacity(0.55)],
        cardBackground: .material(.thin),
        accent: .yellow,
        textPrimary: .white,
        textSecondary: .white.opacity(0.7),
        cellBackground: .material(.ultraThin),
        cellBorder: .white.opacity(0.35),
        iconSystemName: "sparkles",
        animated: false,
        darkVariantID: nil
    )

    static let classic = WordPathTheme(
        id: "classic",
        name: "Clásico",
        backgroundColors: [.indigo, .purple.opacity(0.85), .black.opacity(0.4)],
        cardBackground: .material(.thin),
        accent: .yellow,
        textPrimary: .white,
        textSecondary: .white.opacity(0.6),
        cellBackground: .material(.ultraThin),
        cellBorder: .white.opacity(0.4),
        iconSystemName: "sparkles",
        animated: false,
        darkVariantID: "classic.dark"
    )

    // MARK: Neon
    static let neonDark = WordPathTheme(
        id: "neon.dark",
        name: "Neón (Oscuro)",
        backgroundColors: [.black, .purple.opacity(0.75), .pink.opacity(0.65)],
        cardBackground: .color(Color.black.opacity(0.65)),   // tarjeta más oscura
        accent: .green,
        textPrimary: .white,                                 // letras claras
        textSecondary: .white.opacity(0.55),
        // celdas bastante oscuras para contraste
        cellBackground: .color(Color.black.opacity(0.28)),
        cellBorder: .green.opacity(0.85),
        iconSystemName: "bolt.fill",
        animated: true,
        darkVariantID: nil
    )

    static let neon = WordPathTheme(
        id: "neon",
        name: "Neón",
        backgroundColors: [.black, .purple, .pink],
        cardBackground: .color(Color.black.opacity(0.55)),
        accent: .green,
        textPrimary: .white,                                 // letras claras
        textSecondary: .white.opacity(0.5),
        // celdas más oscuras (antes eran claras y no se veía el texto)
        cellBackground: .color(Color.black.opacity(0.22)),
        cellBorder: .green,
        iconSystemName: "bolt.fill",
        animated: true,
        darkVariantID: "neon.dark"
    )

    /// Factory simple para recuperar un tema por id
    static func from(id: String) -> WordPathTheme {
        switch id {
        case "classic": return .classic
        case "classic.dark": return .classicDark
        case "neon": return .neon
        case "neon.dark": return .neonDark
        case "halloween": return .halloween
        case "halloween.dark": return .halloweenDark
        case "christmas": return .christmas
        case "christmas.dark": return .christmasDark
        case "summer": return .summer
        case "summer.dark": return .summerDark
        case "premiumNight": return .premiumNight
        case "premiumNight.dark": return .premiumNightDark
        case "veteran": return .veteran
        case "veteran.dark": return .veteranDark
        default: return .classic
        }
    }

    func animatedBackground() -> some View {
        if animated {
            return AnyView(AnimatedGradient(colors: backgroundColors))
        } else {
            return AnyView(background)
        }
    }
}

extension WordPathTheme {
    // MARK: Halloween
    static let halloweenDark = WordPathTheme(
        id: "halloween.dark",
        name: "Halloween (Oscuro)",
        backgroundColors: [.black, .orange.opacity(0.7)],
        cardBackground: .material(.thin),
        accent: .orange,
        textPrimary: .white,
        textSecondary: .white.opacity(0.7),
        cellBackground: .material(.ultraThin),
        cellBorder: .orange.opacity(0.8),
        iconSystemName: "moon.fill",
        animated: true,
        darkVariantID: nil
    )

    static let halloween = WordPathTheme(
        id: "halloween",
        name: "Halloween",
        backgroundColors: [.black, .orange.opacity(0.9)],
        cardBackground: .material(.thin),
        accent: .orange,
        textPrimary: .white,
        textSecondary: .white.opacity(0.6),
        cellBackground: .material(.ultraThin),
        cellBorder: .orange.opacity(0.7),
        iconSystemName: "moon.fill",
        animated: true,
        darkVariantID: "halloween.dark"
    )
}

extension WordPathTheme {
    // MARK: Christmas
    static let christmasDark = WordPathTheme(
        id: "christmas.dark",
        name: "Navidad (Oscuro)",
        backgroundColors: [.black, .green.opacity(0.7), .red.opacity(0.6)],
        cardBackground: .material(.thin),
        accent: .green,
        textPrimary: .white,
        textSecondary: .white.opacity(0.75),
        cellBackground: .material(.ultraThin),
        cellBorder: .red.opacity(0.7),
        iconSystemName: "snowflake",
        animated: false,
        darkVariantID: nil
    )

    static let christmas = WordPathTheme(
        id: "christmas",
        name: "Navidad",
        backgroundColors: [.red, .green, .black.opacity(0.4)],
        cardBackground: .material(.thin),
        accent: .green,
        textPrimary: .white,
        textSecondary: .white.opacity(0.7),
        cellBackground: .material(.ultraThin),
        cellBorder: .red.opacity(0.7),
        iconSystemName: "snowflake",
        animated: false,
        darkVariantID: "christmas.dark"
    )
}

extension WordPathTheme {
    // MARK: Summer
    static let summerDark = WordPathTheme(
        id: "summer.dark",
        name: "Verano (Oscuro)",
        backgroundColors: [.orange, .pink, .purple],
        cardBackground: .material(.thin),
        accent: .pink,
        textPrimary: .white,
        textSecondary: .white.opacity(0.85),
        cellBackground: .material(.ultraThin),
        cellBorder: .yellow.opacity(0.75),
        iconSystemName: "sun.max.fill",
        animated: true,
        darkVariantID: nil
    )

    static let summer = WordPathTheme(
        id: "summer",
        name: "Verano",
        backgroundColors: [.yellow, .orange, .pink],
        cardBackground: .material(.thin),
        accent: .pink,
        textPrimary: .white,
        textSecondary: .white.opacity(0.8),
        cellBackground: .material(.ultraThin),
        cellBorder: .yellow.opacity(0.7),
        iconSystemName: "sun.max.fill",
        animated: true,
        darkVariantID: "summer.dark"
    )
}

extension WordPathTheme {
    // MARK: Premium Night
    static let premiumNightDark = WordPathTheme(
        id: "premiumNight.dark",
        name: "Noche Premium (Oscuro)",
        backgroundColors: [.black, .indigo.opacity(0.7), .purple.opacity(0.7)],
        cardBackground: .material(.thin),
        accent: .cyan,
        textPrimary: .white,
        textSecondary: .white.opacity(0.7),
        cellBackground: .material(.ultraThin),
        cellBorder: .cyan.opacity(0.75),
        iconSystemName: "star.fill",
        animated: false,
        darkVariantID: nil
    )

    static let premiumNight = WordPathTheme(
        id: "premiumNight",
        name: "Noche Premium",
        backgroundColors: [.indigo, .purple, .black],
        cardBackground: .material(.thin),
        accent: .cyan,
        textPrimary: .white,
        textSecondary: .white.opacity(0.6),
        cellBackground: .material(.ultraThin),
        cellBorder: .cyan.opacity(0.7),
        iconSystemName: "star.fill",
        animated: false,
        darkVariantID: "premiumNight.dark"
    )
}

extension WordPathTheme {
    // MARK: Veteran
    static let veteranDark = WordPathTheme(
        id: "veteran.dark",
        name: "Veterano (Oscuro)",
        backgroundColors: [
            .black,
            Color(red: 0.18, green: 0.15, blue: 0.11),
            Color(red: 0.45, green: 0.38, blue: 0.25)
        ],
        cardBackground: .material(.thin),
        accent: Color(red: 0.95, green: 0.80, blue: 0.20),
        textPrimary: .white,
        textSecondary: .white.opacity(0.7),
        cellBackground: .material(.ultraThin),
        cellBorder: Color(red: 0.95, green: 0.80, blue: 0.20).opacity(0.75),
        iconSystemName: "crown.fill",
        animated: false,
        darkVariantID: nil
    )

    static let veteran = WordPathTheme(
        id: "veteran",
        name: "Veterano",
        backgroundColors: [
            .black,
            Color(red: 0.25, green: 0.20, blue: 0.15),
            Color(red: 0.60, green: 0.50, blue: 0.35)
        ],
        cardBackground: .material(.thin),
        accent: Color(red: 0.95, green: 0.80, blue: 0.20),
        textPrimary: .white,
        textSecondary: .white.opacity(0.65),
        cellBackground: .material(.ultraThin),
        cellBorder: Color(red: 0.95, green: 0.80, blue: 0.20).opacity(0.75),
        iconSystemName: "crown.fill",
        animated: false,
        darkVariantID: "veteran.dark"
    )
}
