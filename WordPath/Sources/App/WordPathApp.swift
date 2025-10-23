//
//  WordPathApp.swift
//  WordPath
//
//  Created by Jorge Jordán on 21/10/25.
//

import SwiftUI

@main
struct WordPathApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
                .preferredColorScheme(.dark)
                .task {
                    await GameCenterService.shared.authenticate()
                }
        }
    }
}
