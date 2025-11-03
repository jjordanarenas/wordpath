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

    private let key = "WordPath.CurrentTheme"

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
