//
//  StatsManager.swift
//  WordPath
//
//  Created by Jorge Jordán on 8/11/25.
//


import Foundation

@MainActor
final class StatsManager: ObservableObject {
    static let shared = StatsManager()

    @Published private(set) var totalGames: Int = 0
    @Published private(set) var totalWins: Int = 0
    @Published private(set) var totalLosses: Int = 0

    // Futuras: streaks, tiempo promedio, velocidad media, etc.

    private let keyTotalGames = "WP.stats.totalGames"
    private let keyTotalWins  = "WP.stats.totalWins"
    private let keyTotalLoss  = "WP.stats.totalLosses"

    private init() {
        load()
    }

    private func load() {
        let d = UserDefaults.standard
        totalGames  = d.integer(forKey: keyTotalGames)
        totalWins   = d.integer(forKey: keyTotalWins)
        totalLosses = d.integer(forKey: keyTotalLoss)
    }

    private func save() {
        let d = UserDefaults.standard
        d.set(totalGames,  forKey: keyTotalGames)
        d.set(totalWins,   forKey: keyTotalWins)
        d.set(totalLosses, forKey: keyTotalLoss)
    }

    // MARK: - Registro

    func registerGame(win: Bool) {
        totalGames += 1
        if win { totalWins += 1 }
        else   { totalLosses += 1 }
        save()
    }
}
