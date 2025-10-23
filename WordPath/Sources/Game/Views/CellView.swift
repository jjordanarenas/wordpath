//
//  CellView.swift
//  WordPath
//
//  Created by Jorge Jordán on 21/10/25.
//


import SwiftUI

struct CellView: View {
    enum Highlight { case none, selected, glow }

    let cell: Cell
    let selected: Bool
    let highlight: Highlight
    let orderIndex: Int?   // ← NUEVO: posición en la selección (1..10) o nil

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(borderColor, lineWidth: 2)
                        .shadow(radius: highlight == .glow ? 10 : 0)
                )
                .opacity(cell.isHiddenNoise ? 0.2 : 1)

            Text(String(cell.letter))
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .opacity(cell.isHiddenNoise ? 0.25 : 1)
                .scaleEffect(highlight == .selected ? 1.06 : 1)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: highlight)
        }
        // Borde de glow al finalizar
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(highlight == .glow ? .yellow : .clear, lineWidth: 4)
                .blur(radius: 1.2)
        )
        // ★ ya la dibujas arriba-izquierda desde el grid.
        // Número de orden arriba-derecha (solo si está seleccionada esta celda)
        .overlay(alignment: .topTrailing) {
            if let n = orderIndex {
                Text("\(n)")
                    .font(.caption)             // mismo tamaño que la estrella
                    .fontWeight(.bold)
                    .padding(.top, 4)
                    .padding(.trailing, 6)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityLabel("\(cell.letter) \(orderIndex.map(String.init) ?? "")")
    }

    private var borderColor: Color { selected ? .accentColor : .secondary }
}
