//
//  MainMenuView.swift
//  SimplePokerDice
//
//  Created by Amarjit on 02/05/2025.
//

import SwiftUI

struct MainMenuView: View {
    
    
    var body: some View {
        VStack(spacing:30) {
            Spacer()
            Text("Simple Poker Dice")
                .font(.largeTitle)
                .bold()
                .padding(.top, 50)
            
            Button(action: {
                // Do something
            }) {
                Text("Play")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .frame(width: 200, height: 60)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Button(action: {
                // Do something
            }) {
                Text("Settings")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 60)
                    .background(Color.gray)
                    .cornerRadius(10)
            }
            
            Spacer()
            
            /// Current version
            Text("Version: 1.0")
                .font(.footnote)

        }
        .padding()
    }
}

#Preview {
    MainMenuView()
} 
