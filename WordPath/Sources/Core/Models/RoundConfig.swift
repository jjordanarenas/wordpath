//
//  RoundConfig.swift
//  WordPath
//
//  Created by Jorge Jordán on 21/10/25.
//


import Foundation

struct RoundConfig {
    let roundSeconds: Int = 90                // 👈 lo que usa GameViewModel
    let gridSize: Int = 4
    let wordLength: Int = 10
    let totalSeconds: Int = 90
    let eliminationInterval: Int = 10
    let autoHintAtSeconds: Int = 45 // segundos restantes para dar pista
    let noiseCullIntervalSeconds: Int = 10   // 👈 cada 10 s ocultamos una letra de ruido

    // Puntuación (por tramos de 30s: 300 / 200 / 100)
    func score(for secondsLeft: Int) -> Int {
        switch secondsLeft {
        case 61...90: return 300
        case 31...60: return 200
        case 1...30:  return 100
        default:      return 0
        }
    }
}
