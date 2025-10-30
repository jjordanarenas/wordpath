//
//  AdMobRewardedStub.swift
//  WordPath
//
//  Created by Jorge Jordán on 28/10/25.
//


import UIKit

final class AdMobRewardedStub: RewardedAdService {
    static let shared = AdMobRewardedStub()
    private init() {}

    private(set) var isReady: Bool = true   // simulado

    func load() async {
        // Aquí iría la carga real de AdMob (GADRewardedAd.load)
        // En el stub asumimos que está listo
        isReady = true
    }

    func present(from root: UIViewController) async -> Bool {
        // En el stub simulamos que el usuario ve el anuncio y obtiene la recompensa
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1s
        return true // true => conceder recompensa
    }
}
