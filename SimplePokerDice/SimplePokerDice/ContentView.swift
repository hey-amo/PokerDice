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
    @State private var rollingDiceIDs: Set<UUID> = []

    var body: some View {
            VStack(spacing: 20) {
                Text("Poker Dice").font(.largeTitle).bold()

                HStack(spacing: 12) {
                    ForEach(Array(gameState.dice.enumerated()), id: \.1.id) { index, die in
                        DiceFaceView(
                            face: die.face,
                            isHeld: die.isHeld,
                            isRolling: isRolling && rollingDiceIDs.contains(die.id)
                        )
                        .onTapGesture {
                            gameState.toggleHold(for: die.id)
                        }
                    }
                }

                Button("Roll Dice") {
                    // Determine which dice will animate (i.e., not held)
                    rollingDiceIDs = Set(gameState.dice.filter { !$0.isHeld }.map { $0.id })
                    
                    isRolling = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        gameState.rollDice()
                        isRolling = false
                        rollingDiceIDs.removeAll()
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
