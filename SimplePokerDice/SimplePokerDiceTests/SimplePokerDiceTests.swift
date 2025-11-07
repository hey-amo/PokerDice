//
//  SimplePokerDiceTests.swift
//  SimplePokerDiceTests
//
//  Created by Amarjit on 22/04/2025.
//

import XCTest
@testable import SimplePokerDice

final class SimplePokerDiceTests: XCTestCase {

    func testPokerHand_fiveOfAKind() throws {
        let hand: [DiceFace] = [.jack, .jack, .jack, .jack, .jack]
        let result = PokerHandEvaluator.evaluate(hand)
        XCTAssertEqual(result, .fiveOfAKind)
    }
    
    func testPokerHand_fourOfAKind() throws {
        let hand: [DiceFace] = [.jack, .jack, .jack, .jack, .queen]
        let result = PokerHandEvaluator.evaluate(hand)
        XCTAssertEqual(result, .fourOfAKind)
    }
    
    func testPokerHand_FullHouse() throws {
        let hand: [DiceFace] = [.jack, .queen, .jack, .jack, .queen]
        let result = PokerHandEvaluator.evaluate(hand)
        XCTAssertEqual(result, .fullHouse)
    }
    
    func testPokerHand_threeOfAKind() throws {
        let hand: [DiceFace] = [.jack, .jack, .jack, .ace, .queen]
        let result = PokerHandEvaluator.evaluate(hand)
        XCTAssertEqual(result, .threeOfAKind)
    }

    func testPokerHand_twoPair() {
        let hand: [DiceFace] = [
            .jack, .jack,
            .queen, .queen,
            .ace
        ]
        let result = PokerHandEvaluator.evaluate(hand)
        XCTAssertEqual(result, .twoPair, "Expected Two Pair, got \(result.rawValue)")
    }
    
    func testPokerHand_onePair() throws {
        let hand: [DiceFace] = [
                    .nine, .nine,
                    .jack, .queen, .king
                ]
        let result = PokerHandEvaluator.evaluate(hand)
        XCTAssertEqual(result, .onePair, "Expected One Pair, got \(result.rawValue)")
    }
    
    
    func testPokerHand_highCard() throws {
        let hand: [DiceFace] = [.nine, .jack, .queen, .king, .ace]
        let result = PokerHandEvaluator.evaluate(hand)
        XCTAssertEqual(result, .highCard, "Expected High Card, got \(result.rawValue)")
    }
    
    func testPokerHand_noHand() throws {
        /*
        let hand: [DiceFace] = [
                    .blank, .blank, .blank, .blank, .blank
                ]
        let result = PokerHandEvaluator.evaluate(hand)
        XCTAssertEqual(result, .noHand, "Returned: \(result.rawValue)")
         */
    }
    
}
