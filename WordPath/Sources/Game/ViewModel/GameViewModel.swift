//
//  GameViewModel.swift
//  WordPath
//
//  Created by Jorge Jordán on 21/10/25.
//


import Foundation
import SwiftUI

@MainActor
final class GameViewModel: ObservableObject {
    // Config
    let cfg = RoundConfig()

    // Estado público
    @Published var cells: [Cell] = []
    @Published var targetWord: String = ""
    @Published var embeddedPath: [GridPos] = []

    @Published var secondsLeft: Int = 90
    @Published var status: Status = .ready
    @Published var selectedPath: [GridPos] = []
    @Published var hintRevealed: Bool = false
    @Published var scoreAwarded: Int = 0

    // Drag
    @Published var isDragging: Bool = false
    private var lastDragCell: GridPos? = nil

    // Interno
    private var timer: Timer?
    private var lastEliminationTick: Int = 0
    private var wordsPool: [String] = ES10

    enum Status: Equatable {
        case ready
        case running
        case finished(win: Bool)

        static func == (lhs: Status, rhs: Status) -> Bool {
            switch (lhs, rhs) {
            case (.ready, .ready), (.running, .running):
                return true
            case let (.finished(a), .finished(b)):
                return a == b
            default:
                return false
            }
        }
    }

    // MARK: Ciclo de ronda

    func startRound() {
        hintRevealed = false
        selectedPath = []
        scoreAwarded = 0
        secondsLeft = cfg.totalSeconds
        status = .running
        lastEliminationTick = cfg.totalSeconds
        lastDragCell = nil

        var w = (wordsPool.randomElement() ?? "ALGORITMOS").uppercased()
        while w.count != cfg.wordLength { w = (wordsPool.randomElement() ?? "ALGORITMOS").uppercased() }
        targetWord = w

        do {
            let out = try GridGenerator.generateGrid(targetWord: w, size: cfg.gridSize)
            embeddedPath = out.embeddedPath
            cells = out.cells
        } catch {
            let fallback = Array("ABCDEFGHIJKLMNOP")
            cells = (0..<16).map { i in
                let r = i / 4, c = i % 4
                return Cell(id: i, pos: .init(row: r, col: c), letter: fallback[i], isTarget: false)
            }
            embeddedPath = (0..<cfg.wordLength).map { GridPos(row: $0/4, col: $0%4) }
        }

        startTimer()
        Haptics.select(); SFX.tick()
    }

    func stopRound(win: Bool) {
        status = .finished(win: win)
        timer?.invalidate(); timer = nil
        if win { Haptics.success(); SFX.success(); GameCenterService.shared.submit(score: scoreAwarded, leaderboardID: "wordpath.best") }
        else {
            Haptics.error(); SFX.error()
            selectedPath.removeAll()
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            guard self.status == .running else { return }
            self.secondsLeft -= 1
            if self.secondsLeft <= 0 { self.stopRound(win: false) }
            else { self.handleTick() }
        }
    }

    private func handleTick() {
        if !hintRevealed, secondsLeft == cfg.hintAt { hintRevealed = true; Haptics.select(); SFX.blip() }
        if secondsLeft % cfg.eliminationInterval == 0, secondsLeft < lastEliminationTick {
            lastEliminationTick = secondsLeft
            eliminateOneNoiseCell(); SFX.tick()
        }
    }

    private func eliminateOneNoiseCell() {
        let indices = cells.indices.filter { !cells[$0].isTarget && !cells[$0].isHiddenNoise }
        guard let idx = indices.randomElement() else { return }
        cells[idx].isHiddenNoise = true
    }

    // MARK: Selección (tap + drag)

    func resetSelection() { selectedPath.removeAll(); lastDragCell = nil }

    func tapCell(_ cell: Cell) {
        guard status == .running else { return }
        let pos = cell.pos

        // 1) Si tocas la ÚLTIMA seleccionada -> DESHACER
        if let last = selectedPath.last, last == pos {
            withAnimation { _ = selectedPath.popLast() }
            Haptics.tap()
            SFX.blip()
            return
        }

        // 2) Si ya estaba seleccionada pero NO es la última -> IGNORAR (no permite deshacer intermedio)
        if selectedPath.contains(pos) {
            return
        }

        // 3) En otro caso, intenta añadir si es adyacente y no repetida
        addToSelectionIfValid(pos)
    }

    func beginDrag() {
        guard status == .running else { return }
        isDragging = true
        lastDragCell = nil
    }

    func dragOver(cellAt pos: GridPos) {
        guard status == .running, isDragging else { return }
        addToSelectionIfValid(pos)
    }

    func endDrag() {
        isDragging = false
        evaluateIfComplete()
    }

    private func addToSelectionIfValid(_ pos: GridPos) {
        if let last = selectedPath.last {
            guard isAdjacent(a: last, b: pos) else { return }
            guard !selectedPath.contains(pos) else { return }
        }
        if selectedPath.isEmpty { Haptics.tap() } else { Haptics.medium.impactOccurred(intensity: 0.6) }
        SFX.blip()
        selectedPath.append(pos)
        lastDragCell = pos
        if selectedPath.count == cfg.wordLength { evaluateIfComplete() }
    }

    private func isAdjacent(a: GridPos, b: GridPos) -> Bool {
        max(abs(a.row - b.row), abs(a.col - b.col)) == 1
    }

    private func evaluateIfComplete() {
        guard selectedPath.count == cfg.wordLength else { return }
        let formed = String(selectedPath.map { pos in
            let i = pos.row * 4 + pos.col
            return cells[i].letter
        })
        if formed == targetWord {
            scoreAwarded = scoreForCurrentTimeContinuous()
            stopRound(win: true)
        } else {
            Haptics.error(); SFX.error()
            withAnimation { selectedPath.removeAll() }
            lastDragCell = nil
        }
    }

    // MARK: Puntuación continua por tramos
    private func scoreForCurrentTimeContinuous() -> Int {
        let elapsed = cfg.totalSeconds - secondsLeft // 0..90
        func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double { a + (b - a) * t }
        switch elapsed {
        case 0..<30:
            let t = Double(elapsed) / 30.0
            return max(1, Int(round(lerp(300, 201, t))))
        case 30..<60:
            let t = Double(elapsed - 30) / 30.0
            return max(1, Int(round(lerp(200, 101, t))))
        case 60..<90:
            let t = Double(elapsed - 60) / 30.0
            return max(1, Int(round(lerp(100, 1, t))))
        default:
            return 0
        }
    }
}
