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
    private override init() {}

    func configureAccessPoint() {
        GKAccessPoint.shared.location = .topLeading
        GKAccessPoint.shared.isActive = true
    }

    @MainActor
    func authenticate() async {
        GKAccessPoint.shared.location = .topLeading
        GKAccessPoint.shared.isActive = true

        _ = await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            var resumed = false
            func safeResume(_ value: Bool) {
                guard !resumed else { return }
                resumed = true
                continuation.resume(returning: value)
                GKLocalPlayer.local.authenticateHandler = nil
            }

            let lp = GKLocalPlayer.local
            if lp.isAuthenticated { safeResume(true); return }

            guard let root = Self.topViewController() else { safeResume(false); return }

            lp.authenticateHandler = { vc, error in
                if let error {
                    print("GC auth error:", error.localizedDescription)
                }
                if let vc {
                    root.present(vc, animated: true)
                } else {
                    safeResume(lp.isAuthenticated)
                }
            }
        }
    }
    
    /// Autentica y devuelve si quedó autenticado
    func ensureAuthenticated() async -> Bool {
        let lp = GKLocalPlayer.local
        if lp.isAuthenticated { return true }

        // Presentador raíz
        guard let root = Self.topViewController() else { return false }

        return await withCheckedContinuation { continuation in
            var resumed = false
            func safeResume(_ value: Bool) {
                guard !resumed else { return }
                resumed = true
                continuation.resume(returning: value)
                GKLocalPlayer.local.authenticateHandler = nil
            }

            lp.authenticateHandler = { vc, error in
                if let error {
                    print("GC auth error:", error.localizedDescription)
                }

                if let vc {
                    // NO reanudar aquí. El handler se llamará de nuevo sin vc cuando termine el login.
                    root.present(vc, animated: true)
                } else {
                    // Flujo terminado: ya sea autenticado o cancelado
                    safeResume(lp.isAuthenticated)
                }
            }
        }
    }

    func submit(score: Int, leaderboardID: String) {
        Task { @MainActor in
            guard await ensureAuthenticated() else { return }
            let sc = GKScore(leaderboardIdentifier: leaderboardID)
            sc.value = Int64(score)
            GKScore.report([sc]) { err in
                if let err { print("GC submit error:", err.localizedDescription) }
            }
        }
    }

    func showLeaderboards() {
        Task { @MainActor in
            guard await ensureAuthenticated() else { return }
            GKAccessPoint.shared.trigger(state: .leaderboards) {
                print("Leaderboard attempted to open.")
            }
        }
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

    private func present(_ vc: UIViewController) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else { return }
        var top = root
        while let presented = top.presentedViewController { top = presented }
        top.present(vc, animated: true)
    }

    // MARK: - Helpers
    private static func topViewController(base: UIViewController? = {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?.rootViewController
    }()) -> UIViewController? {
        if let nav = base as? UINavigationController { return topViewController(base: nav.visibleViewController) }
        if let tab = base as? UITabBarController { return topViewController(base: tab.selectedViewController) }
        if let presented = base?.presentedViewController { return topViewController(base: presented) }
        return base
    }
}

extension GameCenterService: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
