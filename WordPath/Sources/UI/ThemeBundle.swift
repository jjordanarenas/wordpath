//
//  ThemeBundle.swift
//  WordPath
//
//  Created by Jorge Jordán on 8/11/25.
//


struct ThemeBundle: Identifiable {
    let id: String
    let name: String
    let emoji: String
    let price: Int
    let themes: [String]   // IDs de ThemeItem
}

enum ThemeBundles {
    static let all = [
        ThemeBundle(id: "halloween_pack", name: "Halloween Pack", emoji: "🎃", price: 300,
                    themes: ["halloween", "nightmare", "spooky"])
    ]
}
