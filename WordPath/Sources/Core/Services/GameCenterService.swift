//
//  GameCenterService.swift
//  WordPath
//
//  Created by Jorge Jordán on 21/10/25.
//


import Foundation
import GameKit
import UIKit

@MainActor
final class GameCenterService: ObservableObject {
    static let shared = GameCenterService()
    private init() {}

    func authenticate() async {
        GKAccessPoint.shared.location = .topLeading
        GKAccessPoint.shared.isActive = true

        await withCheckedContinuation { continuation in
            GKLocalPlayer.local.authenticateHandler = { vc, error in
                if let vc {
                    self.present(vc)
                }
                if let error {
                    print("GC auth error: \(error.localizedDescription)")
                }
                continuation.resume()
            }
        }
    }

    func submit(score: Int, leaderboardID: String) {
        if #available(iOS 14.0, *) {
            GKLeaderboard.submitScore(
                score,                       // Int
                context: 0,                  // usa 0 si no utilizas contextos
                player: GKLocalPlayer.local, // jugador local
                leaderboardIDs: [leaderboardID]
            ) { error in
                if let error {
                    print("Submit score error: \(error.localizedDescription)")
                } else {
                    print("Score submitted ✅")
                }
            }
        } else {
            // iOS 13 y anteriores (fallback con GKScore)
            let s = GKScore(leaderboardIdentifier: leaderboardID)
            s.value = Int64(score)
            GKScore.report([s]) { error in
                if let error {
                    print("Submit score error: \(error.localizedDescription)")
                } else {
                    print("Score submitted (legacy) ✅")
                }
            }
        }
    }

    func showLeaderboards() {
        GKAccessPoint.shared.trigger(state: .leaderboards) {
            print("Leaderboard attempted to open.")
        }
    }


    private func present(_ vc: UIViewController) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else { return }
        root.present(vc, animated: true)
    }
}
