//
//  SimplePokerDiceTests.swift
//  SimplePokerDiceTests
//
//  Created by Amarjit on 22/04/2025.
//

import XCTest
@testable import SimplePokerDice

final class SimplePokerDiceTests: XCTestCase {

    func testPokerHandEval() throws {
        let hand: [DiceFace] = [.jack, .queen, .jack, .jack, .queen]
        let rank = PokerHandEvaluator.evaluate(hand)
        print(rank.rawValue)  // Full House
        XCTAssertEqual(rank.rawValue, "Full house")
        XCTAssertEqual(rank, <#T##expression2: Equatable##Equatable#>)
    }
}
