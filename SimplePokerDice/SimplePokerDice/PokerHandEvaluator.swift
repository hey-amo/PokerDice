//
//  PokerHandEvaluator.swift
//  SimplePokerDice
//
//  Created by Amarjit on 22/04/2025.
//


// Simple poker hand evaluator

struct PokerHandEvaluator {
    static func evaluate(_ dice: [DiceFace]) -> HandRank {
        let validRanks = dice
            .map { $0.rawValue }
            .reduce(into: [:]) { counts, rank in
                counts[rank, default: 0] += 1
            }

        let counts = validRanks.values.sorted(by: >)

        switch counts {
        case [5]: return .fiveOfAKind
        case [4, 1]: return .fourOfAKind
        case [3, 2]: return .fullHouse
        case [3, 1, 1]: return .threeOfAKind
        case [2, 2, 1]: return .twoPair
        case [2, 1, 1, 1]: return .onePair
        case [1, 1, 1, 1, 1]: return .highCard
        default: return .noHand
        }
    }
    
    static func calculatePayout(bet: Int, handRank: HandRank) -> Int {
        return Int(Double(bet) * handRank.multiplier)
    }
}
