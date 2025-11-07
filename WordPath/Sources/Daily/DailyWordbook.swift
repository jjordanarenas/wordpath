//
//  DailyWordbook.swift
//  WordPath
//
//  Created by Jorge Jordán on 3/11/25.
//


import Foundation

enum DailyWordbook {
    // ⚠️ Sustituye por tu diccionario real de 10 letras (todas mayúsculas)
    static let words10: [String] = [
        "ALGORITMOS","PROGRAMADO","DESARROLLO","INTERFACES","MICROCHIPT", // ejemplo
        "COMPUTADOR","FRAMEWORKS","INFOTECNIA","TRANSFORME","APLICACION"
    ].filter { $0.count == 10 }

    /// Devuelve un entero semilla estable a partir de yyyy-MM-dd (zona local)
    static func dailySeed(date: Date = Date()) -> Int {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year,.month,.day], from: date)
        // hash simple
        return (comps.year ?? 0) * 10_000 + (comps.month ?? 0) * 100 + (comps.day ?? 0)
    }

    /// Pseudo RNG determinista (LCG simple)
    struct DRand {
        private var state: UInt64
        init(seed: Int) { self.state = UInt64(bitPattern: Int64(seed)) }
        mutating func next() -> UInt64 {
            state = 6364136223846793005 &* state &+ 1442695040888963407
            return state
        }
        mutating func nextInt(_ upper: Int) -> Int {
            Int(next() % UInt64(upper))
        }
    }

    /// Palabra de 10 letras para el día
    static func wordForToday(seed: Int) -> String {
        guard !words10.isEmpty else { return "ALGORITMOS" }
        var r = DRand(seed: seed)
        return words10[r.nextInt(words10.count)]
    }
}
