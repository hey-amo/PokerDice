//
//  Achievements.swift
//  SimplePokerDice
//
//  Created by Amarjit on 07/11/2025.
//

import Foundation
import GameKit

enum AchievementID: String {
    case firstRoll = "first_roll"
    case fullHouse = "full_house"
    case fiveOfAKind = "five_of_a_kind"
    case hotHand = "hot_hand"
}

@MainActor
final class GameCenterManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var playerName: String = ""

    func authenticateUser() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let vc = viewController {
                // Present the Game Center login view in SwiftUI
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = scene.windows.first?.rootViewController {
                    rootVC.present(vc, animated: true)
                }
            } else if GKLocalPlayer.local.isAuthenticated {
                self.isAuthenticated = true
                self.playerName = GKLocalPlayer.local.displayName
                print("Authenticated as \(self.playerName)")
            } else {
                print("Game Centre unavailable: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }

    func unlockAchievement(_ id: String, percent: Double = 100.0) {
        let achievement = GKAchievement(identifier: id)
        achievement.percentComplete = percent
        achievement.showsCompletionBanner = true
        GKAchievement.report([achievement]) { error in
            if let error = error {
                print("Error reporting achievement: \(error.localizedDescription)")
            } else {
                print("Achievement reported: \(id)")
            }
        }
    }
}
