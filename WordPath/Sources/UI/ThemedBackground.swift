//
//  ThemedBackground.swift
//  WordPath
//
//  Created by Jorge Jordán on 30/10/25.
//

import SwiftUI

enum ThemedBackground {
    case color(Color)
    case material(MaterialKind)

    enum MaterialKind: String {
        case ultraThin, thin, regular, thick, ultraThick
    }
}

extension ThemedBackground.MaterialKind {
    var style: SwiftUI.Material {
        switch self {
        case .ultraThin: return .ultraThinMaterial
        case .thin:      return .thinMaterial
        case .regular:   return .regularMaterial
        case .thick:     return .thickMaterial
        case .ultraThick:return .ultraThickMaterial
        }
    }
}
