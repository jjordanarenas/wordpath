//
//  GridGenError.swift
//  WordPath
//
//  Created by Jorge Jordán on 21/10/25.
//


import Foundation

enum GridGenError: Error { case noPath }

struct GridGenerator {
    static func generateGrid(targetWord: String, size: Int = 4)
    throws -> (cells: [Cell], embeddedPath: [GridPos]) {
        precondition(targetWord.count == 10, "Target word must be 10 letters")
        let letters = Array(targetWord.uppercased())

        for _ in 0..<300 {
            if let (path, cells) = try? embedPath(letters: letters, size: size) {
                return (cells, path)
            }
        }
        throw GridGenError.noPath
    }

    private static func embedPath(letters: [Character], size: Int)
    throws -> ([GridPos], [Cell]) {

        func neighbors(of p: GridPos, used: Set<GridPos>) -> [GridPos] {
            let deltas = [(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)]
            return deltas.compactMap { d in
                let r = p.row + d.0
                let c = p.col + d.1
                guard (0..<size).contains(r), (0..<size).contains(c) else { return nil }
                let np = GridPos(row: r, col: c)
                return used.contains(np) ? nil : np
            }.shuffled()
        }

        var path: [GridPos] = []
        var used = Set<GridPos>()
        var current = GridPos(row: Int.random(in: 0..<size), col: Int.random(in: 0..<size))
        used.insert(current)
        path.append(current)

        for _ in 1..<letters.count {
            let options = neighbors(of: current, used: used)
            guard let next = options.randomElement() else { throw GridGenError.noPath }
            current = next
            used.insert(current)
            path.append(current)
        }

        // Construye celdas
        var cells: [Cell] = []
        let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        for r in 0..<size {
            for c in 0..<size {
                let p = GridPos(row: r, col: c)
                if let idx = path.firstIndex(of: p) {
                   // cells.append(Cell(id: p.id, pos: p, letter: letters[idx], isTarget: true))
                    cells.append(Cell(pos: p, letter: letters[idx], isTarget: true))
                } else {
                    var ch = alphabet.randomElement()!
                    if ch == letters.first { ch = alphabet.randomElement()! } // evita pista accidental
                    cells.append(Cell(pos: p, letter: ch, isTarget: false))
                    //cells.append(Cell(id: p.id, pos: p, letter: ch, isTarget: false))
                }
            }
        }
        return (path, cells)
    }
}
