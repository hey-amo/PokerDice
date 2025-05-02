//
//  TopBarView.swift
//  SimplePokerDice
//
//  Created by Amarjit on 02/05/2025.
//

import SwiftUI

struct TopBarView: View {
    @ObservedObject private var router = Router.shared
    
    var body: some View {
        HStack {
            Button(action: {
                print("Btn: Pressed hamburger menu")
                //router.showModal(.menu)
            }) {
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.primary)
                    .imageScale(.large)
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                print("Btn: Pressed gear")
                router.showModal(.settings)
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

#Preview {
    TopBarView()
}
