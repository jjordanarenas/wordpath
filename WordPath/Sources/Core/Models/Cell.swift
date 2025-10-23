//
//  Cell.swift
//  WordPath
//
//  Created by Jorge Jordán on 21/10/25.
//


import Foundation

struct Cell: Identifiable {
    let id: Int
    let pos: GridPos
    let letter: Character
    var isTarget: Bool
    var isHiddenNoise: Bool = false
}
