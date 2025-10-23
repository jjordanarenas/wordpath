//
//  Haptics.swift
//  WordPath
//
//  Created by Jorge Jordán on 21/10/25.
//


import UIKit

enum Haptics {
    static let light = UIImpactFeedbackGenerator(style: .light)
    static let medium = UIImpactFeedbackGenerator(style: .medium)
    static let heavy = UIImpactFeedbackGenerator(style: .heavy)
    static let note = UINotificationFeedbackGenerator()

    static func tap() { light.impactOccurred() }
    static func select() { medium.impactOccurred() }
    static func success() { note.notificationOccurred(.success) }
    static func error() { note.notificationOccurred(.error) }
}
