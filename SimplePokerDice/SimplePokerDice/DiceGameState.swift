//
//  DiceGameState.swift
//  SimplePokerDice
//
//  Created by Amarjit on 22/04/2025.
//
import Foundation

enum GameState: Int {
    case idle, roll, evaluate
}

extension GameState: CustomStringConvertible {
    var description: String {
        switch self {
        case .idle: return "IDLE"
        case .roll: return "ROLLING"
        case .evaluate: return "EVALUATING"
        }
    }
}

enum HandRank: Int {
    case noHand = 0
    case fiveOfAKind, fourOfAKind, fullHouse
    case threeOfAKind, twoPair, onePair
    case highCard
}

extension HandRank: CustomStringConvertible {
    var description: String {
        switch self {
        case .fiveOfAKind: return "Five of a kind"
        case .fourOfAKind: return "Four of a kind"
        case .fullHouse: return "Full house"
        case .threeOfAKind: return "Three of a kind"
        case .twoPair: return "Two pair"
        case .onePair: return "One pair"
        case .highCard: return "High card"
        case .noHand: return "No hand"
        }
    }
}

extension HandRank {
    var score: Int {
        switch self {
        case .fiveOfAKind: return 50
        case .fourOfAKind: return 25
        case .fullHouse: return 15
        case .threeOfAKind: return 10
        case .twoPair: return 5
        case .onePair: return 2
        case .highCard: return 1
        case .noHand: return 0
        }
    }
}

// MARK: Game State

struct DiceGameState {
    var dice: [Die]
    var gameState: GameState = .idle
    var handRank: HandRank = .noHand
    var score: Int = 0
    var round: Int = 0
    
    init() {
        let initialDice = (0..<5).map { _ in Die(face: DiceFace.allCases.randomElement()!) }
        self.dice = initialDice
        self.handRank = PokerHandEvaluator.evaluate(initialDice.map { $0.face })
    }
    
    mutating func rollDice() {        
        for i in dice.indices {
            if !dice[i].isHeld {
                dice[i].face = DiceFace.allCases.randomElement()!
            }
        }
        
        // Evaulate and update score
        handRank = PokerHandEvaluator.evaluate(dice.map { $0.face })
        score += handRank.score
        round += 1
    }
    
    mutating func toggleHold(for dieID: UUID) {
        if let index = dice.firstIndex(where: { $0.id == dieID }) {
            dice[index].isHeld.toggle()
            if dice[index].isHeld {
               print("\nHeld die at position [\(index)]")
            }
        }
    }
    
    
    mutating func reset() {
        self.score = 0
        self.round = 0
    }

}
