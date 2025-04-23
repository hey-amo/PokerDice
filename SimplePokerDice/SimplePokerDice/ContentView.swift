//
//  ContentView.swift
//  SimplePokerDice
//
//  Created by Amarjit on 22/04/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var gameState = DiceGameState()
    @State private var isRolling = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Simple Poker Dice").font(.largeTitle).bold()

            HStack(spacing: 12) {
                ForEach(1..<5, id: \.self) { i in
                    VStack
                    {
                        Text("i: \(i)")
                        
                        DiceFaceView(face: gameState.dice[i], isRolling: isRolling)
                            .frame(width: 60, height: 80)
                    }
                }
            }

            Button("Roll Dice") {
                isRolling = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    gameState.rollDice()
                    isRolling = false
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            Text("Hand: \(gameState.handRank.description)")
            Text("Score: \(gameState.score)")
            Text("Round: \(gameState.round)")
        }
        .padding()
    }
}



#Preview {
    ContentView()
}
