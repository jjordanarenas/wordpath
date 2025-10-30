//
//  RewardedAdService.swift
//  WordPath
//
//  Created by Jorge Jordán on 28/10/25.
//


import UIKit

protocol RewardedAdService: AnyObject {
    var isReady: Bool { get }
    func load() async
    func present(from root: UIViewController) async -> Bool
}
