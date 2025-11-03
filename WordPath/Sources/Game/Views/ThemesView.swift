//
//  ThemesView.swift
//  WordPath
//
//  Created by Jorge Jordán on 30/10/25.
//

import SwiftUI

struct ThemesView: View {
    @ObservedObject var theme = ThemeManager.shared
    var body: some View {
        List(theme.availableThemes) { t in
            HStack {
                Text(t.name)
                Spacer()
                if theme.current.id == t.id {
                    Image(systemName: "checkmark")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                // aquí puedes comprobar si es Premium antes
                theme.setTheme(t)
            }
        }
        .navigationTitle("Temas")
    }
}
