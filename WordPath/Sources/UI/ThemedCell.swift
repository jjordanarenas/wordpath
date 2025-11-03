//
//  ThemedCell.swift
//  WordPath
//
//  Created by Jorge Jordán on 30/10/25.
//

import SwiftUI

struct ThemedCell: View {
    let cell: Cell
    let selected: Bool
    let glow: Bool
    let orderIndex: Int?
    let isHint: Bool
    let theme: WordPathTheme

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.clear)
                .themedBackground(theme.cellBackground, cornerRadius: 16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(selected ? theme.accent : theme.cellBorder, lineWidth: selected ? 3 : 1.5)
                )
                .shadow(radius: glow ? 12 : 1)

            Text(String(cell.letter))
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(theme.textPrimary)
                .opacity(cell.isHiddenNoise ? 0.25 : 1)
                .scaleEffect(selected ? 1.06 : 1)
        }
        .overlay(alignment: .topTrailing) {
            if let n = orderIndex {
                Text("\(n)")
                    .font(isHint ? .caption2 : .caption)
                    .fontWeight(.bold)
                    .padding(.top, 4)
                    .padding(.trailing, 6)
                    .foregroundStyle(isHint ? theme.textSecondary : theme.textPrimary)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 16))
    }
}
