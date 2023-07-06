//
//  CustomTextField.swift
//  VentureVille
//
//  Created by Aayush Rattan on 2023-06-12.
//

import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String
    var isSecure: Bool = false
    
    var body: some View {
        Group {
            if isSecure {
                SecureField("", text: $text)
            } else {
                TextField("", text: $text)
            }
        }
        .placeholder(when: text.isEmpty) {
            Text(placeholder).foregroundColor(.white)
        }
        .textFieldStyle(.plain)
        .font(.title3)
        .frame(maxWidth: .infinity)
        .background(Color.secondary)
        .cornerRadius(50.0)
        .shadow(color: Color.black.opacity(0.08), radius: 60, x: 0.0, y: 16)
        .accentColor(Color("AccentColor"))
        .textFieldStyle(.roundedBorder)
        .padding(30)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
        .padding()
    }
}
