//
//  View+ThemedBackground.swift.swift
//  WordPath
//
//  Created by Jorge Jordán on 30/10/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func themedBackground(_ bg: ThemedBackground, cornerRadius: CGFloat = 0) -> some View {
        switch bg {
        case .color(let c):
            self.background(c, in: RoundedRectangle(cornerRadius: cornerRadius))
        case .material(let kind):
            self.background(kind.style, in: RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}
