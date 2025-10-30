//
//  MissionsManager.swift
//  WordPath
//
//  Created by Jorge Jordán on 28/10/25.
//


import Foundation

enum MissionType: String, Codable, CaseIterable, Identifiable {
    case login, play1, play3, useHint, share
    var id: String { rawValue }
}

struct Mission: Codable, Identifiable {
    let id: MissionType
    var progress: Int = 0
    var goal: Int
    var rewardCoins: Int
    var claimed: Bool = false
}

struct MissionsState: Codable {
    var missions: [MissionType: Mission] = [:]
    var lastDailyReset: Date? = nil
}

@MainActor
final class MissionsManager: ObservableObject {
    static let shared = MissionsManager()
    private init() { load(); dailyResetIfNeeded() }

    @Published private(set) var state = MissionsState()
    private let key = "WordPath.MissionsState"

    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let s = try? JSONDecoder().decode(MissionsState.self, from: data) {
            state = s
        }
        if state.missions.isEmpty {
            state.missions = defaultMissions()
        }
    }
    private func save() {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func isSameDay(_ a: Date?, _ b: Date) -> Bool {
        guard let a else { return false }
        return Calendar.current.isDate(a, inSameDayAs: b)
    }

    func dailyResetIfNeeded(now: Date = Date()) {
        guard !isSameDay(state.lastDailyReset, now) else { return }
        state.missions = defaultMissions()
        state.lastDailyReset = now
        save()
    }

    private func defaultMissions() -> [MissionType: Mission] {
        // Ajusta recompensas: Premium puede ganar hasta 50/día desde EconomyConfig
        return [
            .login: Mission(id: .login, goal: 1, rewardCoins: EconomyConfig.coinsLoginPremium),
            .play1: Mission(id: .play1, goal: 1, rewardCoins: EconomyConfig.coinsPlay1Premium),
            .play3: Mission(id: .play3, goal: 3, rewardCoins: EconomyConfig.coinsPlay3Premium),
            .useHint: Mission(id: .useHint, goal: 1, rewardCoins: EconomyConfig.coinsUseHintPremium),
            .share: Mission(id: .share, goal: 1, rewardCoins: EconomyConfig.coinsShareBoth)
        ]
    }

    func markProgress(_ type: MissionType, amount: Int = 1) {
        guard var m = state.missions[type] else { return }
        guard !m.claimed else { return }
        m.progress = min(m.progress + amount, m.goal)
        state.missions[type] = m
        save()
    }

    func canClaim(_ type: MissionType) -> Bool {
        guard let m = state.missions[type] else { return false }
        return m.progress >= m.goal && !m.claimed
    }

    func claim(_ type: MissionType, economy: EconomyManager, isPremium: Bool) -> Result<Int, Error> {
        guard var m = state.missions[type] else { return .failure(EconomyError.dailyCoinsCapReached) }
        guard canClaim(type) else { return .failure(EconomyError.dailyCoinsCapReached) }

        // Sólo Premium puede reclamar misiones (según diseño). El “share” lo permites para ambos.
        if type != .share && !isPremium {
            return .failure(EconomyError.dailyCoinsCapReached)
        }

        do {
            try economy.addCoins(m.rewardCoins, source: type == .share ? .share : .login)
            m.claimed = true
            state.missions[type] = m
            save()
            return .success(m.rewardCoins)
        } catch {
            return .failure(error)
        }
    }
}
