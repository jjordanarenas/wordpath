//
//  ShareSheet.swift
//  WordPath
//
//  Created by Jorge Jordán on 28/10/25.
//


import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let completion: (Bool) -> Void

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        vc.completionWithItemsHandler = { _, completed, _, _ in
            completion(completed)
        }
        return vc
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
