//
//  PreviewCell.swift
//  WordPath
//
//  Created by Jorge Jordán on 8/11/25.
//


import SwiftUI

struct PreviewCell: View {
    let letter: Character
    let theme: WordPathTheme
    let selected: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .themedBackground(theme.cellBackground, cornerRadius: 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(selected ? theme.accent : theme.cellBorder, lineWidth: selected ? 3 : 1.5)
                )
            Text(String(letter))
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(theme.textPrimary)
        }
    }
}
