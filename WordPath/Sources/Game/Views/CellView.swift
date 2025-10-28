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
    let orderIndex: Int?
    let isHintNumber: Bool

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
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(highlight == .glow ? .yellow : .clear, lineWidth: 4)
                .blur(radius: 1.2)
        )
        .overlay(alignment: .topTrailing) {
            if let n = orderIndex {
                Text("\(n)")
                    .font(isHintNumber ? .caption2 : .caption)
                    .fontWeight(.bold)
                    .padding(.top, 4)
                    .padding(.trailing, 6)
                    .opacity(isHintNumber ? 0.75 : 1.0)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 16))
    }

    private var borderColor: Color { selected ? .accentColor : .secondary }
}
