//
//  EconomyConfig.swift
//  WordPath
//
//  Created by Jorge Jordán on 27/10/25.
//


import Foundation

enum EconomyConfig {
    // Attempts (energía para jugar)
    static let freeDailyAttemptsOnRecharge = 10
    static let rewardedAttemptsPerDayMax = 1        // 1 vez/día
    static let rewardedAttemptsAmount = 3           // +3 intentos cuando se ve anuncio
    static let rechargeCooldownSeconds: TimeInterval = 24*3600

    // Coins (moneda para pistas/temas) – límites de GANANCIA diaria
    static let freeDailyCoinsCap = 20
    static let premiumDailyCoinsCap = 50

    // Fuentes de coins (ajusta a tu gusto)
    static let coinsLoginFree = 0
    static let coinsLoginPremium = 10
    static let coinsPlay1Premium = 10
    static let coinsPlay3Premium = 10
    static let coinsUseHintPremium = 10
    static let coinsShareBoth = 5         // 1 vez/día para ambos

    // Precios
    static let hintCostCoins = 5
}
