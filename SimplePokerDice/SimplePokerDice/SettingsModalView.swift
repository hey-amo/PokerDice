//
//  SettingsModalView.swift
//  SimplePokerDice
//
//  Created by Amarjit on 02/05/2025.
//

import SwiftUI

struct SettingsModalView: View {
    @ObservedObject private var router = Router.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.title)
                .bold()
            
            // Add your settings options here
            Toggle("Sound Effects", isOn: .constant(true))
            Toggle("Vibration", isOn: .constant(true))
            
            Button("Close") {
                router.dismissModal()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .frame(width: 300, height: 250)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}

#Preview {
    SettingsModalView()
} 