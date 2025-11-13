//
//  OwnedThemesStore.swift
//  WordPath
//
//  Created by Jorge Jordán on 8/11/25.
//


import Foundation

@MainActor
final class OwnedThemesStore: ObservableObject {
    static let shared = OwnedThemesStore()
    @Published private(set) var ownedIDs: Set<String> = ["classic"]  // “Clásico” siempre

    private let key = "WordPath.OwnedThemes"

    private init() {
        if let arr = UserDefaults.standard.array(forKey: key) as? [String] {
            ownedIDs = Set(arr + ["classic"])
        }
    }

    private func save() {
        UserDefaults.standard.set(Array(ownedIDs), forKey: key)
    }

    func isOwned(_ id: String) -> Bool { ownedIDs.contains(id) }

    func grant(_ id: String) {
        ownedIDs.insert(id)
        save()
    }
}
