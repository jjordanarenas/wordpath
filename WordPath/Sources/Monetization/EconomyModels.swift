//
//  EconomyModels.swift
//  WordPath
//
//  Created by Jorge Jordán on 27/10/25.
//


import Foundation

struct AttemptsState: Codable {
    var attempts: Int = EconomyConfig.freeDailyAttemptsOnRecharge
    var lastRechargeStart: Date? = nil             // se setea cuando pasas a 0
    var rewardedAttemptsGrantsToday: Int = 0       // control anuncios (+3) 1/día
    var lastDailyReset: Date? = nil                // control “nuevo día”
}

struct CoinsState: Codable {
    var coins: Int = 0
    var dailyEarned: Int = 0                       // ganado hoy
    var lastDailyReset: Date? = nil
}

enum CoinSource: String {
    case login, play1, play3, useHint, share, rewardedAd
}

struct EconomyState: Codable {
    var attempts = AttemptsState()
    var coins = CoinsState()
}

enum EconomyError: Error, LocalizedError {
    case notEnoughAttempts
    case notEnoughCoins
    case dailyCoinsCapReached
    case rewardedAttemptsCapReached
    var errorDescription: String? {
        switch self {
        case .notEnoughAttempts: return "No tienes intentos disponibles."
        case .notEnoughCoins: return "No tienes suficientes coins."
        case .dailyCoinsCapReached: return "Has alcanzado el máximo de coins diarias."
        case .rewardedAttemptsCapReached: return "Ya obtuviste los intentos del anuncio hoy."
        }
    }
}
