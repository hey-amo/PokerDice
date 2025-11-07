//
//  GameView.swift
//  SimplePokerDice
//
//  Created by Amarjit on 22/04/2025.
//

import SwiftUI
import GameKit

struct GameView: View {
    //@EnvironmentObject var gameCenter: GameCenterManager

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
                    
                    // Pass the gameState as an environment object
                    ScoringView()
                        .environmentObject(gameState)
                    
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
                                        
                    Text("Hand: \(gameState.handRank.description)")
                        .frame(width:350, height:50)
                        .font(.headline)
                        .border(.blue)
                        .padding(10)
                    
                    if (gameState.rollsRemaining > 0) {
                        Text("ℹ️ Select dice you wish to keep")
                            .font(.callout)
                            .fontWeight(.medium)
                    } else {
                        Text("ℹ️ You scored: \(gameState.score). Play again?")
                            .font(.callout)
                    }
                    
                    if (gameState.rollsRemaining > 0) {
                        Button("Roll (\(gameState.rollsRemaining))") {
                            // Determine which dice will animate (i.e., not held)
                            rollingDiceIDs = Set(gameState.dice.filter { !$0.isHeld }.map { $0.id })
                            
                            isRolling = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                gameState.rollDice()
                                isRolling = false
                                rollingDiceIDs.removeAll()
                            }
                        }
                        .frame(minWidth: 250)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(gameState.rollsRemaining == 0)
                        
                        Button("Skip") {
                            gameState.skipRolling()
                        }
                        .frame(minWidth: 250)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                    } else {
                        // Play again?
                        Button("Play Again") {
                           gameState.resetGame()
                       }
                        .frame(width: 250)
                       .padding()
                       .background(Color.green)
                       .foregroundColor(.white)
                       .cornerRadius(8)
                    } // endif
                    
                    
                }
            }// end: scrollview
        }
    }
}

// Move ScoringView to be a separate view in the same file
struct ScoringView: View {
    // Use EnvironmentObject to access the gameState
    @EnvironmentObject var gameState: DiceGameState
    
    var body: some View {
        HStack(spacing:180) {
            Text("Score: \(gameState.score)")
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
            Text("Round: \(gameState.round)")
                .multilineTextAlignment(.leading)
                .fontWeight(.bold)
        }.padding(20)
    }
}

#Preview {
    GameView()
}
