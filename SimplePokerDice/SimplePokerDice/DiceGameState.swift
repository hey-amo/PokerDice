//
//  DiceGameState.swift
//  SimplePokerDice
//
//  Created by Amarjit on 22/04/2025.
//

enum GameState: Int {
    case idle, roll, evaluate
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

// MARK: Scoring ranks

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
    var dice: [DiceFace] = Array(repeating: .blank, count: 5)
    var gameState: GameState = .idle
    var handRank: HandRank = .noHand
    var score: Int = 0
    var round: Int = 0
    
    mutating func reset() {
        self.score = 0
        self.round = 0
    }

    mutating func rollDice() {
        dice = (0..<5).map { _ in DiceFace.allCases.randomElement()! }
        handRank = PokerHandEvaluator.evaluate(dice)
        
        score += handRank.score
        round += 1
    }
    
}
