//
//  DailyChallengeManager.swift
//  WordPath
//
//  Created by Jorge Jordán on 3/11/25.
//


import Foundation

@MainActor
final class DailyChallengeManager: ObservableObject {
    static let shared = DailyChallengeManager()

    private let todayProvider: () -> Date

    @Published private(set) var seed: Int = DailyWordbook.dailySeed()
    @Published private(set) var targetWord: String = DailyWordbook.wordForToday(seed: DailyWordbook.dailySeed())
    @Published private(set) var triesUsed: Int = 0        // intentos usados hoy
    @Published private(set) var completed: Bool = false   // ha terminado (acierte o falle)
    @Published private(set) var lastPlayedYMD: String

    // Config
    let freeTriesPerDay = 1
    let extraTryCostCoins = 5

    private let key = "WordPath.DailyChallenge"

    private struct Save: Codable {
        let ymd: String
        let triesUsed: Int
        let completed: Bool
    }

    private init(todayProvider: @escaping () -> Date = { Date() }) {
        self.todayProvider = todayProvider
        lastPlayedYMD = DailyChallengeManager.ymd(todayProvider())
        load()
        refreshIfNewDay()
    }

    // para tests puedes exponer:
    static func testingInstance(today: @escaping () -> Date) -> DailyChallengeManager {
        DailyChallengeManager(todayProvider: today)
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let s = try? JSONDecoder().decode(Save.self, from: data) {
            lastPlayedYMD = s.ymd
            triesUsed = s.triesUsed
            completed = s.completed
        }
        // Inicializa seed y word del día actual
        let s = DailyWordbook.dailySeed()
        seed = s
        targetWord = DailyWordbook.wordForToday(seed: s)
    }

    private func save() {
        let s = Save(ymd: lastPlayedYMD, triesUsed: triesUsed, completed: completed)
        if let data = try? JSONEncoder().encode(s) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func refreshIfNewDay(now: Date = Date()) {
        let today = Self.ymd(now)
        if today != lastPlayedYMD {
            lastPlayedYMD = today
            triesUsed = 0
            completed = false
            seed = DailyWordbook.dailySeed(for: now)
            targetWord = DailyWordbook.wordForToday(seed: seed)
            save()
        }
    }

    func refreshIfNewDay() {
        let today = todayProvider()
        let todayYMD = Self.ymd(today)
        guard todayYMD != lastPlayedYMD else { return }

        lastPlayedYMD = todayYMD
        let sd = DailyWordbook.dailySeed(for: today)
        seed = sd
        targetWord = DailyWordbook.wordForToday(seed: sd)
        triesUsed = 0
        completed = false
        save()
    }

    static func ymd(_ date: Date) -> String {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone.current  // usamos el huso horario del usuario

        let comps = cal.dateComponents([.year, .month, .day], from: date)

        // construimos una fecha “normalizada” al inicio del día local
        let normalized = cal.date(from: comps) ?? date

        let f = DateFormatter()
        f.calendar = cal
        f.timeZone = cal.timeZone
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: normalized)
    }

    var freeTryAvailable: Bool { triesUsed < freeTriesPerDay }
    var canPlayNow: Bool { !completed && (freeTryAvailable || EconomyManager.shared.coins >= extraTryCostCoins) }

    /// Llama cuando el usuario pulsa "Jugar reto diario"
    func startDailyRound(using vm: GameViewModel) -> Bool {
        refreshIfNewDay()
        guard !completed else { return false }

        if freeTryAvailable {
            triesUsed += 1
            save()
        } else {
            // cobra coins por reintento (no consume intentos globales)
            do { try EconomyManager.shared.spendCoins(extraTryCostCoins) } catch { return false }
            triesUsed += 1
            save()
        }

        // Arranca una partida con seed/word forzadas (no consumir attempts globales)
        vm.startDaily(seed: seed, forcedWord: targetWord)
        return true
    }

    /// Marca que el reto se ha completado (acierte o falle)
    func finishDailyRound() {
        completed = true
        save()
    }
}

#if DEBUG
extension DailyChallengeManager {
    @MainActor
    func debugShift(to date: Date) {
        // Recalcular seed y palabra como haría un día real
        let sd = DailyWordbook.dailySeed(for: date)
        let word = DailyWordbook.wordForToday(seed: sd)

        self.seed = sd
        self.targetWord = word
        self.lastPlayedYMD = Self.ymd(date)
        self.triesUsed = 0
        self.completed = false
    }
}
#endif
