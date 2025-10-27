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
final class GameCenterService: NSObject, ObservableObject {
    static let shared = GameCenterService()
    //private init() {}
    private override init() { super.init() }

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

    /*func showLeaderboards() {
        GKAccessPoint.shared.trigger(state: .leaderboards) {
            print("Leaderboard attempted to open.")
        }
    }*/
    func showLeaderboards() {
        guard GKLocalPlayer.local.isAuthenticated else {
            // Si no estás autenticado, intenta autenticación y luego presenta
            Task {
                await authenticate()
                presentLeaderboardsModal()
            }
            return
        }

        // iOS 17+: primero intentamos el AccessPoint…
        if #available(iOS 17.0, *) {
            GKAccessPoint.shared.isActive = true
            GKAccessPoint.shared.location = .topLeading
            GKAccessPoint.shared.trigger(state: .leaderboards) {
                // Si en tu dispositivo “no hace nada”, usamos el fallback modal:
                // (Este handler no indica éxito/fracaso; por eso usamos modal si ves que no aparece)
            }
        }

        // Fallback universal y pre-iOS17: modal (fiable)
        presentLeaderboardsModal()
    }

    private func presentLeaderboardsModal() {
        if #available(iOS 14.0, *) {
            let gcVC = GKGameCenterViewController(state: .leaderboards)
            gcVC.gameCenterDelegate = self
            present(gcVC)
        } else {
            // iOS 13 y anteriores
            let gcVC = GKGameCenterViewController()
            gcVC.gameCenterDelegate = self
            gcVC.viewState = .leaderboards
            present(gcVC)
        }
    }

    /*private func present(_ vc: UIViewController) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else { return }
        root.present(vc, animated: true)
    }*/
    private func present(_ vc: UIViewController) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else { return }
        var top = root
        while let presented = top.presentedViewController { top = presented }
        top.present(vc, animated: true)
    }
}

extension GameCenterService: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
