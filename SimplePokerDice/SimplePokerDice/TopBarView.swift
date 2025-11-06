//
//  TopBarView.swift
//  SimplePokerDice
//
//  Created by Amarjit on 02/05/2025.
//

import SwiftUI

struct TopBarView: View {
    var body: some View {
        HStack {
            
            Spacer()
            
            Button(action: {
                print("BTN: Pressed gear")
                // launch settings modal
            }) {
                Image(systemName: "gear")
                    .foregroundColor(.primary)
                    .imageScale(.large)
            }
            .padding(.horizontal)
        }
        .frame(height: 44)
        .background(Color(.systemBackground))
    }
}
