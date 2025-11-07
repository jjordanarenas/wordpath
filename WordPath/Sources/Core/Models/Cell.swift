//
//  Cell.swift
//  WordPath
//
//  Created by Jorge Jordán on 21/10/25.
//


import Foundation

struct Cell: Identifiable {
    let id: UUID
    let pos: GridPos
    let letter: Character
    var isTarget: Bool
    var isHiddenNoise: Bool = false

    init(pos: GridPos, letter: Character, isHiddenNoise: Bool = false, isTarget: Bool = false) {
        self.id = UUID()
        self.pos = pos
        self.letter = letter
        self.isHiddenNoise = isHiddenNoise
        self.isTarget = isTarget
    }
}
