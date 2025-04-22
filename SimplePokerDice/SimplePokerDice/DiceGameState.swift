//
//  DiceGameState.swift
//  SimplePokerDice
//
//  Created by Amarjit on 22/04/2025.
//

enum GameState: Int {
    case idle
    case roll
    case evaluate
}

enum HandRank: String {
    case fiveOfAKind, fourOfAKind, fullHouse
    case threeOfAKind, twoPair, onePair
    case highCard, none
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
        case .none: return "No hand"
        }
    }
}

struct DiceGameState {
    var dice: [DiceFace] = []
    var gameState: GameState = .idle
    var handRank: HandRank = .none

    mutating func rollDice() {
        dice = (0..<5).map { _ in DiceFace.allCases.randomElement()! }
        handRank = PokerHandEvaluator.evaluate(dice)
    }
}
