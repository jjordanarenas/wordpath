//
//  GameView.swift
//  WordPath
//
//  Created by Jorge Jordán on 21/10/25.
//


import SwiftUI

struct GameView: View {
    @StateObject private var vm = GameViewModel()
    @State private var revealStep: Int = -1

    // Métricas
    private let cellSize: CGFloat = 72
    private let spacing: CGFloat = 12

    var body: some View {
        VStack(spacing: 12) {
            header
            topBars
            gridWithDrag
            controls
        }
        .padding(16)
        .onAppear { vm.onAppearEconomyTick() }
        .onChange(of: vm.status) { _, st in if case .finished = st { startRevealAnimation() } }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("WORDPATH").font(.title.bold())
                if vm.hintRevealed || vm.status != .running {
                    Text("Empieza por: \(vm.targetWord.first.map { String($0) } ?? "?")")
                        .font(.footnote.monospaced())
                        .transition(.opacity)
                } else {
                    Text(" ") // placeholder para mantener altura
                        .font(.footnote)
                        .opacity(0)
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("Tiempo")
                Text(timeString(vm.secondsLeft))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                if case .finished(let win) = vm.status {
                    Text(win ? "+\(vm.scoreAwarded)" : "💔")
                        .font(.headline)
                        .foregroundStyle(win ? .green : .red)
                }
            }
        }
    }

    // MARK: Top bars with attempts/coins
    private var topBars: some View {
        HStack {
            // Intentos (energía)
            HStack(spacing: 6) {
                Text("💛 \(vm.attempts)")
                    .font(.headline.monospacedDigit())
                if let remain = vm.rechargeRemaining, vm.attempts == 0 {
                    Text("⏳ \(format(remain))").font(.caption).foregroundStyle(.secondary)
                }
            }
            Spacer()
            // Coins
            Text("🟡 \(vm.coins)")
                .font(.headline.monospacedDigit())
        }
    }

    // MARK: Grid + numbering logic
    private var gridWithDrag: some View {
        GeometryReader { proxy in
            let gridSide = cellSize * 4 + spacing * 3
            ZStack {
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(cellSize), spacing: spacing), count: 4), spacing: spacing) {
                    ForEach(vm.cells) { cell in
                        let orderInfo = orderFor(cell: cell)
                        CellView(
                            cell: cell,
                            selected: vm.selectedPath.contains(cell.pos),
                            highlight: highlightState(for: cell),
                            orderIndex: orderInfo.number,
                            isHintNumber: orderInfo.isHint
                        )
                        .frame(width: cellSize, height: cellSize)
                        .onTapGesture { vm.tapCell(cell) }
                        .overlay(alignment: .topLeading) {
                            if vm.hintRevealed && vm.status == .running && cell.pos == vm.embeddedPath.first {
                                Text("★").font(.caption)
                            }
                        }
                    }
                }
                // Drag overlay
                Rectangle().fill(.clear).frame(width: gridSide, height: gridSide)
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                vm.beginDrag()
                                let origin = CGPoint(x: (proxy.size.width - gridSide)/2, y: 0)
                                let local = CGPoint(x: value.location.x - origin.x, y: value.location.y - origin.y)
                                let col = Int(floor(local.x / (cellSize + spacing)))
                                let row = Int(floor(local.y / (cellSize + spacing)))
                                guard (0..<4).contains(row), (0..<4).contains(col) else { return }
                                vm.dragOver(cellAt: GridPos(row: row, col: col))
                            }
                            .onEnded { _ in vm.endDrag() }
                    )
            }
            .frame(width: gridSide, height: gridSide)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .frame(height: cellSize * 4 + spacing * 3 + 8)
    }

    /*private var grid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(cellSize), spacing: spacing), count: 4), spacing: spacing) {
            ForEach(vm.cells) { cell in
                // Calcula el índice de selección (1-based) si esta celda está en la ruta seleccionada
                let order: Int? = {
                    if case .finished(let win) = vm.status, !win {
                        // Estamos enseñando la solución: numerar el camino correcto
                        if let idx = vm.embeddedPath.firstIndex(of: cell.pos), idx <= revealStep {
                            return idx + 1 // 1-based
                        }
                        return nil
                    } else {
                        // Juego en curso o ganó: numerar la selección del jugador
                        if let idx = vm.selectedPath.firstIndex(of: cell.pos) {
                            return idx + 1 // 1-based
                        }
                        return nil
                    }
                }()

                CellView(
                    cell: cell,
                    selected: vm.selectedPath.contains(cell.pos),
                    highlight: highlightState(for: cell),
                    orderIndex: order                // ← NUEVO
                )
                .frame(width: cellSize, height: cellSize)
                .onTapGesture { vm.tapCell(cell) }
                // Estrella de pista arriba-izquierda (se mantiene como antes)
                .overlay(alignment: .topLeading) {
                    if vm.hintRevealed && vm.status == .running && cell.pos == vm.embeddedPath.first {
                        Text("★").font(.caption)
                    }
                }
                .accessibilityLabel(String(cell.letter))
            }
        }
        .padding(.vertical, 8)
    }*/

    // Números a mostrar: solución (tras perder) -> revealStep; si no, selección o pista
    private func orderFor(cell: Cell) -> (number: Int?, isHint: Bool) {
        if case .finished(let win) = vm.status, !win {
            if let idx = vm.embeddedPath.firstIndex(of: cell.pos), idx <= revealStep {
                return (idx + 1, false)
            }
            return (nil, false)
        } else {
            if let idx = vm.selectedPath.firstIndex(of: cell.pos) { return (idx + 1, false) }
            if let idx = vm.embeddedPath.firstIndex(of: cell.pos), vm.hintedIndices.contains(idx) {
                return (idx + 1, true)
            }
            return (nil, false)
        }
    }

    private func highlightState(for cell: Cell) -> CellView.Highlight {
        if case .finished = vm.status {
            if let step = vm.embeddedPath.firstIndex(of: cell.pos) { return step <= revealStep ? .glow : .none }
        }
        return vm.selectedPath.contains(cell.pos) ? .selected : .none
    }

    // MARK: Controls row
    private var controls: some View {
        HStack(spacing: 8) {
            Button(vm.status == .running ? "Reiniciar" : "Jugar") { vm.startRound() }
                .buttonStyle(.borderedProminent)
                .disabled(!vm.canPlay && vm.status != .running)

            Button("Usar pista (5)") { vm.useHint() }
                .buttonStyle(.bordered)
                .disabled(!(vm.status == .running) || vm.coins < EconomyConfig.hintCostCoins)

            Spacer()

            Button("Leaderboard") { Task { @MainActor in GameCenterService.shared.showLeaderboards() } }
        }
    }

    // Reveal anim
    private func startRevealAnimation() {
        revealStep = -1
        let total = vm.embeddedPath.count
        Task { @MainActor in
            for i in 0..<total {
                try? await Task.sleep(nanoseconds: 160_000_000)
                withAnimation(.easeOut(duration: 0.16)) { revealStep = i }
            }
        }
    }

    private func timeString(_ s: Int) -> String {
        String(format: "%d:%02d", s/60, s%60)
    }

    private func format(_ seconds: TimeInterval) -> String {
        let s = Int(max(0, seconds))
        let h = s / 3600
        let m = (s % 3600) / 60
        let sec = s % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, sec) : String(format: "%d:%02d", m, sec)
    }
}
