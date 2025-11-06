//
//  SettingsModalView.swift
//  SimplePokerDice
//
//  Created by Amarjit on 02/05/2025.
//

import SwiftUI

struct SettingsViewModel {
    let sfx: Bool
    let darkMode: Bool
}

struct SettingsModalView: View {
        
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.title)
                .bold()
            
            Toggle("Sounds", isOn: .constant(true))
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
