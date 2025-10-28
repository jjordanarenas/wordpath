//
//  EconomyManager.swift
//  WordPath
//
//  Created by Jorge Jordán on 27/10/25.
//


import Foundation

@MainActor
final class EconomyManager: ObservableObject {
    static let shared = EconomyManager()
    private init() { load() }

    @Published private(set) var state = EconomyState()
    private let key = "WordPath.EconomyState"

    // MARK: Persistence
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let s = try? JSONDecoder().decode(EconomyState.self, from: data) {
            state = s
        }
        dailyResetIfNeeded()
        tickRechargeIfNeeded()
    }
    private func save() {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // MARK: Daily reset (coins y contadores)
    private func isSameDay(_ a: Date?, _ b: Date) -> Bool {
        guard let a else { return false }
        return Calendar.current.isDate(a, inSameDayAs: b)
    }
    func dailyResetIfNeeded(now: Date = Date()) {
        // Attempts rewarded grant reset
        if !isSameDay(state.attempts.lastDailyReset, now) {
            state.attempts.rewardedAttemptsGrantsToday = 0
            state.attempts.lastDailyReset = now
        }
        // Coins daily earned reset
        if !isSameDay(state.coins.lastDailyReset, now) {
            state.coins.dailyEarned = 0
            state.coins.lastDailyReset = now
        }
        save()
    }

    // MARK: Attempts (energía)
    var attempts: Int { state.attempts.attempts }
    var canPlay: Bool {
        SubscriptionManager.shared.isPremium || attempts > 0
    }

    func startGame() throws {
        dailyResetIfNeeded()
        tickRechargeIfNeeded()
        if SubscriptionManager.shared.isPremium { return }
        guard state.attempts.attempts > 0 else { throw EconomyError.notEnoughAttempts }
        state.attempts.attempts -= 1
        if state.attempts.attempts == 0 {
            state.attempts.lastRechargeStart = Date() // arranca cooldown 24h
        }
        save()
    }

    func grantRewardedAttempts() throws {
        dailyResetIfNeeded()
        guard state.attempts.rewardedAttemptsGrantsToday < EconomyConfig.rewardedAttemptsPerDayMax
        else { throw EconomyError.rewardedAttemptsCapReached }
        state.attempts.attempts += EconomyConfig.rewardedAttemptsAmount
        state.attempts.rewardedAttemptsGrantsToday += 1
        save()
    }

    func timeUntilRecharge(now: Date = Date()) -> TimeInterval? {
        guard state.attempts.attempts == 0, let start = state.attempts.lastRechargeStart else { return nil }
        let elapsed = now.timeIntervalSince(start)
        let remain = EconomyConfig.rechargeCooldownSeconds - elapsed
        return remain > 0 ? remain : 0
    }

    func tickRechargeIfNeeded(now: Date = Date()) {
        guard state.attempts.attempts == 0, let start = state.attempts.lastRechargeStart else { return }
        if now.timeIntervalSince(start) >= EconomyConfig.rechargeCooldownSeconds {
            state.attempts.attempts = EconomyConfig.freeDailyAttemptsOnRecharge
            state.attempts.lastRechargeStart = nil
            save()
        }
    }

    // MARK: Coins (moneda para pistas/temas)
    var coins: Int { state.coins.coins }

    private var dailyCap: Int {
        SubscriptionManager.shared.isPremium ? EconomyConfig.premiumDailyCoinsCap : EconomyConfig.freeDailyCoinsCap
    }

    func addCoins(_ amount: Int, source: CoinSource) throws {
        dailyResetIfNeeded()
        guard amount > 0 else { return }
        guard state.coins.dailyEarned + amount <= dailyCap else { throw EconomyError.dailyCoinsCapReached }
        state.coins.coins += amount
        state.coins.dailyEarned += amount
        save()
    }

    func spendCoins(_ amount: Int) throws {
        guard state.coins.coins >= amount else { throw EconomyError.notEnoughCoins }
        state.coins.coins -= amount
        save()
    }
}
