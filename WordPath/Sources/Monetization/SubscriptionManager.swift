//
//  SubscriptionManager.swift
//  WordPath
//
//  Created by Jorge Jordán on 27/10/25.
//


import Foundation

final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    private init() {}
    // TODO: enlazar con StoreKit2 cuando quieras
    @Published var isPremium: Bool = false
}
