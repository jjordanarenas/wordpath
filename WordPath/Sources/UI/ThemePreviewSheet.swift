//
//  ThemePreviewSheet.swift
//  WordPath
//
//  Created by Jorge Jordán on 8/11/25.
//


import SwiftUI

struct ThemePreviewSheet: View {
    let item: ThemeItem
    @Environment(\.dismiss) var dismiss

    let demoLetters = Array("WORDPATHGAMEPLAY").prefix(16)

    var body: some View {
        ZStack {
            item.theme.animatedBackground().ignoresSafeArea()

            VStack(spacing: 20) {
                Text(item.displayName)
                    .font(.largeTitle.bold())
                    .foregroundStyle(item.theme.textPrimary)

                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4), spacing: 8) {
                    ForEach(Array(demoLetters.enumerated()), id: \.offset) { i, ch in
                        PreviewCell(letter: ch, theme: item.theme, selected: i % 5 == 0)
                            .frame(height: 60)
                    }
                }.padding(12)

                Button("Cerrar") { dismiss() }
                    .font(.headline)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 32)
                    .background(.white.opacity(0.9), in: Capsule())
            }
        }
    }
}
