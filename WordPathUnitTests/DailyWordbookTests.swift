//
//  DailyWordbookTests.swift
//  WordPath
//
//  Created by Jorge Jordán on 14/11/25.
//

import XCTest
@testable import WordPath

final class DailyWordbookTests: XCTestCase {
    func testSameDateProducesSameWord() {
        let cal = Calendar(identifier: .gregorian)
        let date = cal.date(from: DateComponents(year: 2025, month: 11, day: 10))!

        let seed1 = DailyWordbook.dailySeed(for: date)
        let seed2 = DailyWordbook.dailySeed(for: date)

        XCTAssertEqual(seed1, seed2)

        let w1 = DailyWordbook.wordForToday(seed: seed1)
        let w2 = DailyWordbook.wordForToday(seed: seed2)

        XCTAssertEqual(w1, w2, "La misma fecha debería producir siempre la misma palabra")
    }

    func testDifferentDatesProduceDifferentWords() {
        let cal = Calendar(identifier: .gregorian)
        let d1 = cal.date(from: DateComponents(year: 2025, month: 11, day: 10))!
        let d2 = cal.date(from: DateComponents(year: 2025, month: 11, day: 11))!

        let s1 = DailyWordbook.dailySeed(for: d1)
        let s2 = DailyWordbook.dailySeed(for: d2)

        XCTAssertNotEqual(s1, s2, "Fechas distintas deberían tener seeds distintos")

        let w1 = DailyWordbook.wordForToday(seed: s1)
        let w2 = DailyWordbook.wordForToday(seed: s2)

        XCTAssertNotEqual(w1, w2, "Idealmente, días distintos deberían tener palabras distintas (al menos en un rango razonable)")
    }
}
