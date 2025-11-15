//
//  DailyChallengeManagerTests.swift
//  WordPath
//
//  Created by Jorge Jordán on 14/11/25.
//


// DailyChallengeManagerTests.swift
import XCTest
@testable import WordPath

import XCTest
@testable import WordPath

@MainActor
final class DailyChallengeManagerTests: XCTestCase {

    func testNewDayChangesSeed() {
        let cal = Calendar(identifier: .gregorian)
        let day1 = cal.date(from: DateComponents(year: 2025, month: 11, day: 10))!
        let day2 = cal.date(from: DateComponents(year: 2025, month: 11, day: 11))!

        let manager = DailyChallengeManager.testingInstance {
            day1
        }

        manager.refreshIfNewDay(now: day1)
        let seed1 = manager.seed

        manager.refreshIfNewDay(now: day2)
        let seed2 = manager.seed

        XCTAssertNotEqual(seed1, seed2, "Al cambiar de día debe cambiar la semilla del reto diario")
    }


    func testSameDayKeepsWordAndSeed() {
        let cal = Calendar(identifier: .gregorian)
        let date = cal.date(from: DateComponents(year: 2025, month: 11, day: 10))!

        let manager = DailyChallengeManager.testingInstance {
            date
        }

        manager.refreshIfNewDay(now: date)
        let seed1 = manager.seed
        let word1 = manager.targetWord

        // misma fecha otra vez
        manager.refreshIfNewDay(now: date)
        let seed2 = manager.seed
        let word2 = manager.targetWord

        XCTAssertEqual(seed1, seed2)
        XCTAssertEqual(word1, word2)
    }

    func testYMDFormatIsCorrect() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!  // para que sea estable en cualquier máquina

        let date = cal.date(from: DateComponents(
            year: 2025,
            month: 11,
            day: 10,
            hour: 15,
            minute: 30
        ))!

        let ymd = DailyChallengeManager.ymd(date)

        XCTAssertEqual(ymd, "2025-11-10", "La función ymd debe formatear la fecha como yyyy-MM-dd")
    }

    func testYMDIsTheSameForDifferentTimesSameDay() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone.current

        let morning = cal.date(from: DateComponents(
            year: 2025,
            month: 11,
            day: 10,
            hour: 1,
            minute: 5
        ))!

        let night = cal.date(from: DateComponents(
            year: 2025,
            month: 11,
            day: 10,
            hour: 23,
            minute: 59
        ))!

        let ymdMorning = DailyChallengeManager.ymd(morning)
        let ymdNight   = DailyChallengeManager.ymd(night)

        XCTAssertEqual(ymdMorning, ymdNight, "Horas diferentes del mismo día deben producir el mismo ymd")
    }

    func testYMDDiffersOnDifferentDays() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone.current

        let d1 = cal.date(from: DateComponents(year: 2025, month: 11, day: 10, hour: 12))!
        let d2 = cal.date(from: DateComponents(year: 2025, month: 11, day: 11, hour: 12))!

        let y1 = DailyChallengeManager.ymd(d1)
        let y2 = DailyChallengeManager.ymd(d2)

        XCTAssertNotEqual(y1, y2, "Fechas con días distintos deben producir distintos ymd")
    }

    func testWordsVaryOverMultipleDays() {
        let cal = Calendar(identifier: .gregorian)
        let base = cal.date(from: DateComponents(year: 2025, month: 1, day: 1))!

        // 👇 En vez de fatalError, usamos una fecha fija cualquiera
        let manager = DailyChallengeManager.testingInstance {
            base
        }

        var words: Set<String> = []

        for day in 0..<30 {
            let date = cal.date(byAdding: .day, value: day, to: base)!
            manager.refreshIfNewDay(now: date)
            words.insert(manager.targetWord)
        }

        XCTAssertGreaterThan(
            words.count,
            1,
            "En 30 días debería haber, como mínimo, más de una palabra distinta"
        )
    }

}
