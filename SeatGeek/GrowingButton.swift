//
//  GrowingButton.swift
//  VentureVille
//
//  Created by Aayush Rattan on 2023-06-12.
//

import SwiftUI

struct GrowingButton: ButtonStyle {
    var width:CGFloat?
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .bold()
            .frame(width: width)
            .background(.white)
            .foregroundColor(.black)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
