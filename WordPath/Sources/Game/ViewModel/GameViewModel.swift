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

    @Published var secondsLeft: Int = 0//90
    @Published var status: Status = .ready
    @Published var selectedPath: [GridPos] = []
    @Published var hintRevealed: Bool = false
    @Published var scoreAwarded: Int = 0

    // Drag
    @Published var isDragging: Bool = false

    @Published var hintedIndices: Set<Int> = []       // índices 0..9 en embeddedPath

    private var lastDragCell: GridPos? = nil

    // Dependencias
    private let economy = EconomyManager.shared
    private let subs = SubscriptionManager.shared

    // Interno
    private var timer: Timer?
    private var lastEliminationTick: Int = 0
    private var wordsPool: [String] = ES10

    // Exponer saldos a la vista
    var attempts: Int { economy.attempts }
    var coins: Int { economy.coins }
    var canPlay: Bool { economy.canPlay }
    var rechargeRemaining: TimeInterval? { economy.timeUntilRecharge() }
    var isPremium: Bool { subs.isPremium }
    var onRoundFinished: ((Bool) -> Void)?   // win -> Bool
    var isDaily: Bool = false                // marca si la ronda es “reto diario”

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

    // Llamar al empezar (botón Jugar)
    func startRound() {
        guard canPlay else { return } // la vista ya muestra CTA “ver anuncio/suscribirse”
        do { try economy.startGame() } catch { return }

        timer?.invalidate()
        timer = nil
        hintRevealed = false
        selectedPath = []
        scoreAwarded = 0
        secondsLeft = cfg.totalSeconds
        status = .running
        lastEliminationTick = cfg.totalSeconds
        lastDragCell = nil
        scheduleTick()

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
                return Cell(pos: .init(row: r, col: c), letter: fallback[i], isTarget: false)
                //return Cell(id: i, pos: .init(row: r, col: c), letter: fallback[i], isTarget: false)
            }
            embeddedPath = (0..<cfg.wordLength).map { GridPos(row: $0/4, col: $0%4) }
        }

        startTimer()
        Haptics.select(); SFX.tick()
        hintedIndices.removeAll()
    }

    // Botón “Usar pista (5)”
    func useHint() {
        guard status == .running else { return }
        do {
            try economy.spendCoins(EconomyConfig.hintCostCoins)
        } catch {
            // opcional: mostrar alerta “no tienes coins”
            return
        }
        // elegir índice no revelado / no seleccionado
        let path = embeddedPath
        let selectedSet = Set(selectedPath)
        let available = path.enumerated()
            .filter { (i, pos) in !hintedIndices.contains(i) && !selectedSet.contains(pos) }
            .map { $0.offset }
        guard let idx = available.randomElement() else { return }
        hintedIndices.insert(idx)
        Haptics.select(); SFX.blip()

        MissionsManager.shared.markProgress(.useHint)

        // (opcional) coins por “usar pista” si premium (misión diaria)
        if isPremium {
            try? economy.addCoins(EconomyConfig.coinsUseHintPremium, source: .useHint)
        }
    }

    func stopRound(win: Bool) {
        status = .finished(win: win)
        timer?.invalidate(); timer = nil
        // ✅ MISIÓN: ha jugado 1 partida (incrementa progreso de play1 y play3)
        MissionsManager.shared.markProgress(.play1)
        MissionsManager.shared.markProgress(.play3)

        if win {
            Haptics.success();
            SFX.success();
            GameCenterService.shared.submit(score: scoreAwarded, leaderboardID: "wordpath.best") }
        else {
            Haptics.error(); SFX.error()
            selectedPath.removeAll()
        }

        // 🔔 Notifica al que te haya inscrito el callback
        onRoundFinished?(win)
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
        if !hintRevealed, secondsLeft == cfg.autoHintAtSeconds { hintRevealed = true; Haptics.select(); SFX.blip() }
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

    // Al abrir app o tab principal
    func onAppearEconomyTick() {
        EconomyManager.shared.dailyResetIfNeeded()
        EconomyManager.shared.tickRechargeIfNeeded()
    }

    func scheduleTick() {
        // Evita timers duplicados
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func tick() {
        guard status == .running else { return }
        guard secondsLeft > 0 else {
            timer?.invalidate(); timer = nil
            stopRound(win: false)
            return
        }

        secondsLeft -= 1

        // Pista automática a los 45s (no cuenta como pista manual)
        if secondsLeft == cfg.roundSeconds - cfg.autoHintAtSeconds {
            // En nuestro modelo: cfg.roundSeconds = 90, autoHintAtSeconds = 45
            // Cuando quedan 45s, muestra la estrella en la primera letra
            hintRevealed = true
            Haptics.select(); SFX.blip()
        }

        // Cada 10s ocultar una letra de ruido (no perteneciente al path objetivo)
        let elapsed = cfg.roundSeconds - secondsLeft
        if elapsed > 0 && elapsed % cfg.noiseCullIntervalSeconds == 0 {
            hideOneNoiseCell()
        }
    }

    private func hideOneNoiseCell() {
        // Candidatos: celdas que NO están en el path de la palabra y aún no están ocultas
        let pathSet = Set(embeddedPath)
        let candidates = cells.indices.filter { i in
            !pathSet.contains(cells[i].pos) && !cells[i].isHiddenNoise
        }
        guard let pick = candidates.randomElement() else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            cells[pick].isHiddenNoise = true
        }
    }
}

// En GameViewModel.swift
extension GameViewModel {
    /// Arranca una ronda DIARIA con seed y palabra forzadas. NO consume Economy.attempts.
    func startDaily(seed: Int, forcedWord: String) {
        // Limpia estado
        timer?.invalidate(); timer = nil
        selectedPath.removeAll()
        hintedIndices.removeAll()
        lastDragCell = nil

        // Ajusta la palabra objetivo
        targetWord = forcedWord
        // Genera un grid determinista con seed para embebido del path
        generateDeterministicGrid(seed: seed, word: forcedWord)

        // Arranca el temporizador y estado
        secondsLeft = cfg.roundSeconds
        status = .running
        scheduleTick() 
    }

    /// Genera grid/embeddedPath de forma determinista (ejemplo simple)
    func generateDeterministicGrid(seed: Int, word: String) {
        // 1) Genera un camino de 10 celdas únicas contiguas (usando un DRand similar)
        struct DRand { var s: UInt64; mutating func next()->UInt64 { s = 6364136223846793005 &* s &+ 1442695040888963407; return s }
            mutating func nextInt(_ u:Int)->Int { Int(next() % UInt64(u)) } }
        var r = DRand(s: UInt64(bitPattern: Int64(seed)))

        var path: [GridPos] = []
        func neighbors(of p: GridPos) -> [GridPos] {
            var arr:[GridPos]=[]
            for dr in -1...1 {
                for dc in -1...1 where !(dr == 0 && dc == 0) {
                    let nr = p.row + dr, nc = p.col + dc
                    if (0..<4).contains(nr) && (0..<4).contains(nc) {
                        let np = GridPos(row: nr, col: nc)
                        if !path.contains(np) { arr.append(np) }
                    }
                }
            }
            return arr
        }
        // elige inicio aleatorio
        var start = GridPos(row: r.nextInt(4), col: r.nextInt(4))
        path.append(start)
        while path.count < word.count {
            let opts = neighbors(of: start)
            if opts.isEmpty {
                // reset si nos atascamos
                path.removeAll()
                start = GridPos(row: r.nextInt(4), col: r.nextInt(4))
                path.append(start)
                continue
            }
            let next = opts[r.nextInt(opts.count)]
            path.append(next)
            start = next
        }
        embeddedPath = path

        // 2) Rellena celdas con las letras de la palabra en el path y ruido en el resto
        var letters = Array(word).map { Character(String($0).uppercased()) }
        var allCells: [Cell] = []
        for row in 0..<4 {
            for col in 0..<4 {
                let pos = GridPos(row: row, col: col)
                if let idx = path.firstIndex(of: pos) {
                    allCells.append(Cell(pos: pos, letter: letters[idx], isHiddenNoise: false))
                } else {
                    // ruido: letra aleatoria A..Z
                    let code = 65 + r.nextInt(26)
                    let ch = Character(UnicodeScalar(code)!)
                    allCells.append(Cell(pos: pos, letter: ch, isHiddenNoise: false))
                }
            }
        }
        cells = allCells
    }
}
