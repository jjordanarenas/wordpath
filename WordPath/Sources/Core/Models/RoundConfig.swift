//
//  RoundConfig.swift
//  WordPath
//
//  Created by Jorge Jordán on 21/10/25.
//


import Foundation

struct RoundConfig {
    let gridSize: Int = 4
    let wordLength: Int = 10
    let totalSeconds: Int = 90
    let eliminationInterval: Int = 10
    let hintAt: Int = 45 // segundos restantes para dar pista
}
