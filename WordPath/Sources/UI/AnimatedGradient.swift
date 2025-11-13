//
//  AnimatedGradient.swift
//  WordPath
//
//  Created by Jorge Jordán on 8/11/25.
//


import SwiftUI

struct AnimatedGradient: View {
    let colors: [Color]
    @State private var flip = false

    var body: some View {
        LinearGradient(colors: flip ? colors : colors.reversed(),
                       startPoint: .top, endPoint: .bottom)
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    flip = true
                }
            }
    }
}
