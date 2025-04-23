//
//  ContentView.swift
//  SimplePokerDice
//
//  Created by Amarjit on 22/04/2025.
//

import SwiftUI

struct ContentView: View {
    /*
    @State private var currentDie = Int.random(in: 0...6)

    var body: some View {
        VStack {
            DiceFaceView(index: currentDie)
                .frame(width: 100, height: 100)

            Button("Roll") {
                currentDie = Int.random(in: 1...6)
            }
        }
    }*/
    @State private var gameState = DiceGameState()
    var body: some View {
            VStack(spacing: 20) {
                Text("Poker Dice")
                    .font(.largeTitle)
                    .bold()

                HStack(spacing: 12) {
                    ForEach(0..<5, id: \.self) { index in
                        DiceFaceView(index: gameState.dice.indices.contains(index) ? gameState.dice[index].rawValue : 0)
                            .frame(width: 60, height: 60)
                    }
                }

                Button("Roll Dice") {
                    gameState.rollDice()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

                Text("Hand: \(gameState.handRank.description)")
                    .font(.headline)
                    .padding(.top)
            }
            .padding()
        }
}


#Preview {
    ContentView()
}
