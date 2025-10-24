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
        VStack(spacing: 16) {
            header
            gridWithDrag
            controls
        }
        .padding(20)
        .onChange(of: vm.status) { _, st in
            if case .finished = st { startRevealAnimation() }
        }
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
                    Text(" ").font(.footnote)
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

    private var gridWithDrag: some View {
        GeometryReader { proxy in
            let gridSide = cellSize * 4 + spacing * 3
            VStack {
                ZStack {
                    grid
                    Rectangle()
                        .fill(.clear)
                        .frame(width: gridSide, height: gridSide)
                        .highPriorityGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    vm.beginDrag()
                                    let origin = CGPoint(
                                        x: (proxy.size.width - gridSide)/2,
                                        y: 0
                                    )
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
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(height: cellSize * 4 + spacing * 3 + 8)
    }

    private var grid: some View {
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
    }

    private func highlightState(for cell: Cell) -> CellView.Highlight {
        if case .finished = vm.status {
            if let step = vm.embeddedPath.firstIndex(of: cell.pos) {
                return step <= revealStep ? .glow : .none
            }
        }
        return vm.selectedPath.contains(cell.pos) ? .selected : .none
    }

    private var controls: some View {
        HStack {
            Button(vm.status == .running ? "Reiniciar" : "Jugar") {
                vm.startRound()
            }
            .buttonStyle(.borderedProminent)

            Spacer()

            Button("Leaderboard") {
                GameCenterService.shared.showLeaderboards()
            }
        }
    }

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
}
