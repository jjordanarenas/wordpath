//
//  ThemeManager.swift
//  WordPath
//
//  Created by Jorge Jordán on 30/10/25.
//
    

import SwiftUI

@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var current: WordPathTheme = .classic
    // ✅ Guardamos un String en UserDefaults
    @AppStorage("WordPath.colorScheme") 
    private var storedColorScheme: String = "system"

    @AppStorage("WordPath.colorMode")
    private var storedMode: String = ThemeColorMode.system.rawValue

    private let key = "WordPath.CurrentTheme"

    var mode: ThemeColorMode {
        get { ThemeColorMode(rawValue: storedMode) ?? .system }
        set { storedMode = newValue.rawValue }
    }

    var colorScheme: ColorScheme {
        get {
            switch storedColorScheme {
            case "light": return .light
            case "dark":  return .dark
            default:      return .light   // si usas modo "sistema", puedo darte esa versión también
            }
        }
        set {
            switch newValue {
            case .light: storedColorScheme = "light"
            case .dark:  storedColorScheme = "dark"
            @unknown default:
                storedColorScheme = "light"
            }
        }
    }

    var effectiveTheme: WordPathTheme {
        switch mode {
        case .light:
            return current

        case .dark:
            if let darkID = current.darkVariantID {
                return WordPathTheme.from(id: darkID)
            }
            return current

        case .system:
            let systemIsDark = UITraitCollection.current.userInterfaceStyle == .dark
            if systemIsDark, let darkID = current.darkVariantID {
                return WordPathTheme.from(id: darkID)
            }
            return current
        }
    }

    private init() {
        if let savedId = UserDefaults.standard.string(forKey: key) {
            current = WordPathTheme.from(id: savedId)
        } else {
            current = .classic
        }
    }

    func setTheme(_ theme: WordPathTheme) {
        current = theme
        UserDefaults.standard.set(theme.id, forKey: key)
    }

    var availableThemes: [WordPathTheme] {
        [.classic, .neon]
    }
}

enum ThemeColorMode: String {
    case system
    case light
    case dark
}
