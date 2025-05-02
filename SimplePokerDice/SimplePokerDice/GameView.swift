//
//  GameView.swift
//  SimplePokerDice
//
//  Created by Amarjit on 22/04/2025.
//

import SwiftUI
import UIKit

struct GameView: View {
    @State private var gameState = DiceGameState()
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
                    
                    Text("Simple Poker Dice").font(.largeTitle).bold()
                                        
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
                    
                    Text("Hand: \(gameState.handRank.description)").padding(20)
                    
                    HStack(spacing:180) {
                        Text("Score: \(gameState.score)")
                            .multilineTextAlignment(.leading)
                        Text("Round: \(gameState.round)")
                            .multilineTextAlignment(.leading)
                    }.padding(20)
                }
            }// end: scrollview
        }
    }
}

#Preview {
    GameView()
}
