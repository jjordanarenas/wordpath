//
//  SeededRandomNumberGenerator.swift
//  WordPath
//
//  Created by Jorge Jordán on 14/11/25.
//


/// Un generador LCG (Linear Congruential Generator) simple pero determinista.
/// Rápido, estable y suficiente para un juego de palabras.
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        // LCG estándar usado por glibc y otros sistemas clásicos:
        // Xₙ₊₁ = (a * Xₙ + c) mod m
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}
