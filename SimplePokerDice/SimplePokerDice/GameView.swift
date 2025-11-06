//
//  GameView.swift
//  SimplePokerDice
//
//  Created by Amarjit on 22/04/2025.
//

import SwiftUI

struct GameView: View {
    @StateObject private var gameState = DiceGameState()
    @State private var isRolling = false
    @State private var rollingDiceIDs: Set<UUID> = []

    var body: some View {
        
        VStack(spacing: 0) {
            TopBarView()
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.systemBackground))
                .zIndex(1)
                        
            ScrollView {
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text("Simple Poker Dice")
                        .font(.largeTitle)
                        .bold()
                                        
                    HStack(spacing: 12) {
                        ForEach(Array(gameState.dice.enumerated()), id: \.1.id) { index, die in
                            
                            DiceFaceView(
                                face: die.face,
                                isHeld: die.isHeld,
                                isRolling: isRolling && rollingDiceIDs.contains(die.id)
                            )
                            .onTapGesture {
                                // only allow hold if rollsRemain
                                if (gameState.rollsRemaining > 0) {
                                    gameState.toggleHold(for: die.id)
                                }
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
                    .disabled(gameState.rollsRemaining == 0)
                    
                    Text("Hand: \(gameState.handRank.description)").padding(20)
                    Text("Rolls Remaining: \(gameState.rollsRemaining)")
                        .font(.headline)
                        .foregroundColor(gameState.rollsRemaining == 0 ? .red : .primary)
                                        
                    HStack(spacing:180) {
                        Text("Score: \(gameState.score)")
                            .multilineTextAlignment(.leading)
                        Text("Round: \(gameState.round)")
                            .multilineTextAlignment(.leading)
                    }.padding(20)

                    // Play again?
                    if (gameState.rollsRemaining == 0) {
                         Button("Play Again") {
                            gameState.resetGame()
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }// end: scrollview
        }
    }
}

#Preview {
    GameView()
}
