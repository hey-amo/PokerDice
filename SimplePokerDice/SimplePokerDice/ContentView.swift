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
                Text("Poker Dice").font(.largeTitle).bold()

                HStack(spacing: 12) {
                    ForEach(gameState.dice) { die in
                        DiceFaceView(face: die.face, isHeld: die.isHeld, isRolling: isRolling)
                            .onTapGesture {
                                gameState.toggleHold(for: die.id)
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
