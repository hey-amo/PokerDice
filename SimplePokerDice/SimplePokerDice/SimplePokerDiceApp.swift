//
//  SimplePokerDiceApp.swift
//  SimplePokerDice
//
//  Created by Amarjit on 22/04/2025.
//

import SwiftUI
import GameKit

@main
struct SimplePokerDiceApp: App {
    @StateObject private var gameCenterManager = GameCenterManager()
    
    var body: some Scene {
        WindowGroup {
            GameView()
               .environmentObject(gameCenterManager)
               .task {
                   gameCenterManager.authenticateUser()
               }
       }
    }
}

/*
func authenticateLocalPlayer() {
    GKLocalPlayer.local.authenticateHandler = { viewController, error in
        if let vc = viewController {
            // Present the Game Centre login screen
            UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true)
        } else if GKLocalPlayer.local.isAuthenticated {
            print("Player authenticated: \(GKLocalPlayer.local.displayName)")
        } else {
            print("Game Centre disabled or unavailable: \(error?.localizedDescription ?? "")")
        }
    }
}

 
*/
