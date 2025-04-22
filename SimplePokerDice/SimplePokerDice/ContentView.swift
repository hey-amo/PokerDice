//
//  ContentView.swift
//  SimplePokerDice
//
//  Created by Amarjit on 22/04/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var currentDie = Int.random(in: 0...6)

    var body: some View {
        VStack {
            DiceFaceView(index: currentDie)
                .frame(width: 100, height: 100)

            Button("Roll") {
                currentDie = Int.random(in: 0...6)
            }
        }
    }
}


#Preview {
    ContentView()
}
