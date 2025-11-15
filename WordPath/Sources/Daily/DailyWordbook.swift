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
        "ALGORITMOS","ALMACENADO","ALTERNADOR","ANTIAEREOS",/*"ARQUITECTO","ATMOSFERAS",
        "AEROPUERTO","AERONAUTAS","BIOGRAFIAS","BIBLIOTECA","BOTELLAZOS","BUSCADORES",
        "CALENDARIO","CALIBRADOR","CAPITANEOS","CARRETERAS","CARTOGRAFO","CIRCULARES",
        "COMPUTADOR","COMBUSTION","CONTRATADO","DIRECTORIO","ENCRIPTADO","EQUILIBRIO",
        "FABRICANTE","FOTOGRAFIA","FRAGMENTOS","FUNCIONADO","GENERADORES","GEOMETRICO",
        "GOBERNADOR","HIPERTEXTO","HUMANIDADES","ILUMINADOR","IMPRESORAS","INDICADORES",
        "INGENIEROS","JARDINEROS","JUGUETERIA","LANZADORES","LATERALIDAD","LIDERAZGOS",
        "MAGNETICAS","MANTENEDOR","MATRICULAS","METALURGIA","MICROFONOS","NAVEGACION",
        "NEBULOSIDAD","NORMALIDAD","OPERACIONES","ORBITACION","ORGANIZADO","ORQUESTADO",
        "PARTITURAL","PERFORADOR","PLANETARIO","PROGRAMADO","RADARISTAS","RASTREADOR",
        "REACTIVADO","REGULACION","RENDIMIENTO","SOBRECARGA","SUBSISTEMA","TERRITORIO",
        "TERMOSTATO","TRANSVERSO","TRIANGULAR","TURBINADOS","UNIVERSIDAD","URBANISTAS",
        "VENTILADOR","VERIFICADO","XILOFONIAS","YODIFICADO","ZAPATERIAS","ZONIFICADO"*/
    ].filter { $0.count == 10 }

    /// Devuelve un entero semilla estable a partir de yyyy-MM-dd (zona local)
    static func dailySeed(for date: Date = Date()) -> Int {
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
        // aquí tu lista de palabras y rng determinista con seed
        let words = ["ALGORITMOS","ALMACENADO","ALTERNADOR","ANTIAEREOS"]
        var rng = SeededRandomNumberGenerator(seed: UInt64(seed))
        return words.randomElement(using: &rng) ?? "ALGORITMOS"
    }
}
