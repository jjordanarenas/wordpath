//
//  GameView.swift
//  WordPath
//
//  Created by Jorge Jordán on 21/10/25.
//

import SwiftUI

struct GameView: View {
    @StateObject private var vm: GameViewModel
    @ObservedObject private var theme = ThemeManager.shared

    @State private var revealStep: Int = -1
    @State private var showShare = false

    private let cellSize: CGFloat = 72
    private let spacing: CGFloat = 12
    private var onDailyFinished: (() -> Void)?

    // 1) Init cuando ya traes un VM (p. ej., desde el reto diario)
    @MainActor
    init(viewModel: GameViewModel, onDailyFinished: (() -> Void)? = nil) {
        _vm = StateObject(wrappedValue: viewModel)
        self.onDailyFinished = onDailyFinished
    }

    // 2) Init “por defecto” que crea el VM en el MainActor (para Home → Jugar)
    @MainActor
    init(onDailyFinished: (() -> Void)? = nil) {
        _vm = StateObject(wrappedValue: GameViewModel())
        self.onDailyFinished = onDailyFinished
    }

    var body: some View {
        ZStack {
            // FONDO DEL TEMA
            theme.effectiveTheme.animatedBackground()
                .ignoresSafeArea()

            VStack(spacing: 12) {
                header
                topBars
                gridWithDrag
                controls
            }
            .padding(16)
        }
        .onAppear {
            vm.onAppearEconomyTick()
        }
        .onChange(of: vm.status) { _, st in
            if case .finished = st {
                startRevealAnimation()
            }
        }
        .overlay {
            if case .finished(let win) = vm.status {
                EndOfRoundBanner(
                    win: win,
                    score: vm.scoreAwarded,
                    targetWord: vm.targetWord,
                    onPlayAgain: { vm.startRound() },
                    onLeaderboard: {
                        Task { @MainActor in
                            GameCenterService.shared.showLeaderboards()
                        }
                    },
                    onShare: { showShare = true }
                )
            }
        }
        .sheet(isPresented: $showShare) {
            let text = vm.status == .finished(win: true)
                ? "¡He conseguido \(vm.scoreAwarded) puntos en WordPath! ¿Puedes superarlo?"
                : "Hoy no la acerté en WordPath. La palabra era \(vm.targetWord). ¡Rétame!"
            ShareSheet(items: [text]) { completed in
                if completed {
                    MissionsManager.shared.markProgress(.share)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showShare = false
                        withAnimation(.spring()) {
                            vm.startRound()
                        }
                    }
                } else {
                    showShare = false
                }
            }
        }
    }

    // MARK: Header
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("WORDPATH")
                    .font(.title.bold())
                    .foregroundStyle(theme.effectiveTheme.textPrimary)

                if vm.hintRevealed || vm.status != .running {
                    Text("Empieza por: \(vm.targetWord.first.map { String($0) } ?? "?")")
                        .font(.footnote.monospaced())
                        .foregroundStyle(theme.effectiveTheme.textSecondary)
                        .transition(.opacity)
                } else {
                    Text(" ")
                        .font(.footnote)
                        .opacity(0)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if vm.status == .running {
                    Text("Tiempo")
                        .foregroundStyle(theme.effectiveTheme.textSecondary)
                    Text(timeString(vm.secondsLeft))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.effectiveTheme.textPrimary)
                        .contentTransition(.numericText())
                } else if case .finished(let win) = vm.status {
                    Text(win ? "+\(vm.scoreAwarded)" : "💔")
                        .font(.headline)
                        .foregroundStyle(win ? .green : .red)
                }
            }
        }
    }

    // MARK: Top bar (intentos + coins)
    private var topBars: some View {
        HStack {
            HStack(spacing: 6) {
                Text("💛 \(vm.attempts)")
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(theme.effectiveTheme.textPrimary)
                if let remain = vm.rechargeRemaining, vm.attempts == 0 {
                    Text("⏳ \(format(remain))")
                        .font(.caption)
                        .foregroundStyle(theme.effectiveTheme.textSecondary)
                }
            }
            Spacer()
            Text("🟡 \(vm.coins)")
                .font(.headline.monospacedDigit())
                .foregroundStyle(theme.effectiveTheme.textPrimary)
        }
    }

    // MARK: Grid
    private var gridWithDrag: some View {
        GeometryReader { proxy in
            let gridSide = cellSize * 4 + spacing * 3
            ZStack {
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(cellSize), spacing: spacing), count: 4), spacing: spacing) {
                    ForEach(vm.cells) { cell in
                        let orderInfo = orderFor(cell: cell)
                        ThemedCell(
                            cell: cell,
                            selected: vm.selectedPath.contains(cell.pos),
                            glow: glowState(for: cell),
                            orderIndex: orderInfo.number,
                            isHint: orderInfo.isHint,
                            theme: theme.effectiveTheme
                        )
                        .frame(width: cellSize, height: cellSize)
                        .onTapGesture { vm.tapCell(cell) }
                        .overlay(alignment: .topLeading) {
                            if vm.hintRevealed && vm.status == .running && cell.pos == vm.embeddedPath.first {
                                Text("★").font(.caption).foregroundStyle(.yellow)
                            }
                        }
                    }
                }

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

    // MARK: Controls – SOLO gameplay
    private var controls: some View {
        HStack(spacing: 8) {
            Button(vm.status == .running ? "Reiniciar" : "Jugar") {
                vm.startRound()
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .foregroundStyle(.indigo)
            .disabled(!vm.canPlay && vm.status != .running)

            Button("Usar pista (5)") {
                vm.useHint()
            }
            .buttonStyle(.bordered)
            .tint(.white.opacity(0.3))
            .disabled(!(vm.status == .running) || vm.coins < EconomyConfig.hintCostCoins)

            Spacer()

            Button {
                Task { @MainActor in
                    GameCenterService.shared.showLeaderboards()
                }
            } label: {
                Image(systemName: "trophy.fill")
            }
            .buttonStyle(.bordered)
            .tint(.yellow.opacity(0.7))
        }
    }

    // MARK: Helpers
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

    private func glowState(for cell: Cell) -> Bool {
        if case .finished = vm.status {
            if let step = vm.embeddedPath.firstIndex(of: cell.pos) {
                return step <= revealStep
            }
        }
        return false
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

    private func format(_ seconds: TimeInterval) -> String {
        let s = Int(max(0, seconds))
        let h = s / 3600, m = (s % 3600) / 60, sec = s % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, sec) : String(format: "%d:%02d", m, sec)
    }
}
