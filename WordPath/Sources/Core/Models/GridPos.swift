//
//  GridPos.swift
//  WordPath
//
//  Created by Jorge Jordán on 21/10/25.
//

import Foundation

struct GridPos: Hashable, Identifiable {
    let row: Int
    let col: Int
    var id: Int { row * 4 + col }
}
