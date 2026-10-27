import XCTest
@testable import PokerDice

final class PokerDiceTests: XCTestCase {
    private let evaluator = PokerHandEvaluator()

    func testEvaluatorRecognizesEveryHandCategory() throws {
        print("Evaluating all Poker Dice hand categories")
        let cases: [([DieFace], HandCategory)] = [
            ([.ace, .ace, .ace, .ace, .ace], .fiveOfAKind),
            ([.king, .king, .king, .king, .nine], .fourOfAKind),
            ([.queen, .queen, .queen, .ten, .ten], .fullHouse),
            ([.nine, .ten, .jack, .queen, .king], .straight),
            ([.ten, .jack, .queen, .king, .ace], .straight),
            ([.jack, .jack, .jack, .ace, .nine], .threeOfAKind),
            ([.ace, .ace, .king, .king, .nine], .twoPair),
            ([.queen, .queen, .ace, .king, .nine], .onePair),
            ([.ace, .king, .queen, .ten, .nine], .highCard)
        ]

        for (dice, expectedCategory) in cases {
            XCTAssertEqual(try evaluator.evaluate(dice).category, expectedCategory, "\(dice)")
        }
    }

    func testEvaluatorUsesTieBreakersAndCategoryRanking() throws {
        print("Comparing hand ranks and tie-break values")
        let fourKings = try evaluator.evaluate([.king, .king, .king, .king, .nine])
        let fourQueens = try evaluator.evaluate([.queen, .queen, .queen, .queen, .ace])
        let fullHouse = try evaluator.evaluate([.ace, .ace, .ace, .nine, .nine])
        let lowStraight = try evaluator.evaluate([.nine, .ten, .jack, .queen, .king])
        let highStraight = try evaluator.evaluate([.ten, .jack, .queen, .king, .ace])
        let pairOfAces = try evaluator.evaluate([.ace, .ace, .king, .queen, .nine])
        let pairOfAcesLowerKicker = try evaluator.evaluate([.ace, .ace, .king, .jack, .nine])
        let twoHighPairs = try evaluator.evaluate([.ace, .ace, .king, .king, .nine])
        let twoLowPairs = try evaluator.evaluate([.queen, .queen, .jack, .jack, .ace])
        let strongFullHouse = try evaluator.evaluate([.ace, .ace, .ace, .nine, .nine])
        let weakFullHouse = try evaluator.evaluate([.king, .king, .king, .ace, .ace])
        let strongHighCard = try evaluator.evaluate([.ace, .king, .queen, .ten, .nine])
        let weakHighCard = try evaluator.evaluate([.ace, .king, .jack, .ten, .nine])

        XCTAssertEqual(evaluator.compare(fourKings, fourQueens), .orderedDescending)
        XCTAssertEqual(evaluator.compare(fourKings, fullHouse), .orderedDescending)
        XCTAssertEqual(evaluator.compare(highStraight, lowStraight), .orderedDescending)
        XCTAssertEqual(evaluator.compare(pairOfAces, pairOfAcesLowerKicker), .orderedDescending)
        XCTAssertEqual(evaluator.compare(twoHighPairs, twoLowPairs), .orderedDescending)
        XCTAssertEqual(evaluator.compare(strongFullHouse, weakFullHouse), .orderedDescending)
        XCTAssertEqual(evaluator.compare(strongHighCard, weakHighCard), .orderedDescending)
        XCTAssertEqual(
            evaluator.compare(
                try evaluator.evaluate([.ace, .king, .queen, .ten, .nine]),
                try evaluator.evaluate([.ace, .king, .queen, .ten, .nine])
            ),
            .orderedSame
        )
    }

    func testEvaluatorRejectsInvalidHandSize() {
        print("Checking invalid hand sizes are rejected")
        XCTAssertThrowsError(try evaluator.evaluate([.ace, .king, .queen, .ten]))
        XCTAssertThrowsError(try evaluator.evaluate([.ace, .king, .queen, .ten, .nine, .nine]))
    }

    func testGameRerollsOnlyUnheldDiceAndCompletesTwoPlayerGame() throws {
        print("Starting deterministic two-player game")
        let roller = StubDiceRoller(rolls: [
            [.ace, .ace, .nine, .ten, .jack],
            [.queen, .king, .nine],
            [.king, .king, .king, .king, .king]
        ])
        let game = PokerDiceGame(diceRoller: roller)
        var state = game.startNewGame()

        XCTAssertEqual(state.phase, .playing(.playerOne))
        state = try game.roll(state)
        XCTAssertEqual(state[handFor: .playerOne].dice, [.ace, .ace, .nine, .ten, .jack])
        print("Player 1 rolled five dice")

        state = try game.setHeldDice([0, 1], in: state)
        state = try game.roll(state)
        XCTAssertEqual(state[handFor: .playerOne].dice, [.ace, .ace, .queen, .king, .nine])
        XCTAssertEqual(state[handFor: .playerOne].rollsUsed, 2)
        print("Player 1 kept the pair of Aces and rerolled the other three")

        state = try game.finishTurn(state)
        XCTAssertEqual(state.phase, .awaitingHandoff(.playerTwo))
        state = try game.confirmHandoff(state)
        XCTAssertEqual(state.phase, .playing(.playerTwo))
        state = try game.roll(state)
        state = try game.finishTurn(state)

        XCTAssertEqual(state.phase, .finished(.winner(.playerTwo)))
        XCTAssertTrue(state[handFor: .playerOne].isComplete)
        XCTAssertTrue(state[handFor: .playerTwo].isComplete)
        print("Player 2 won with Five of a Kind")
    }

    func testGameAllowsEarlyFinishAndDraw() throws {
        print("Checking early finish and tied hands")
        let roller = StubDiceRoller(rolls: [
            [.ace, .ace, .king, .king, .nine],
            [.ace, .ace, .king, .king, .nine]
        ])
        let game = PokerDiceGame(diceRoller: roller)
        var state = game.startNewGame()
        state = try game.roll(state)
        state = try game.finishTurn(state)
        state = try game.confirmHandoff(state)
        state = try game.roll(state)
        state = try game.finishTurn(state)

        XCTAssertEqual(state.phase, .finished(.draw))
        print("Both players tied with the same Two Pair hand")

        let restartedState = game.startNewGame()
        XCTAssertEqual(restartedState.phase, .playing(.playerOne))
        XCTAssertTrue(PlayerID.allCases.allSatisfy {
            restartedState[handFor: $0] == PlayerHand()
        })
        print("A new game starts with clean player hands")
    }

    func testGameRejectsInvalidTransitionsAndRollLimits() throws {
        print("Checking turn, hold, and roll-limit validation")
        let roller = StubDiceRoller(rolls: [
            [.nine, .ten, .jack, .queen, .king],
            [.nine],
            [.ten],
            [.jack]
        ])
        let game = PokerDiceGame(diceRoller: roller)
        var state = game.startNewGame()

        XCTAssertThrowsError(try game.confirmHandoff(state))
        XCTAssertThrowsError(try game.setHeldDice([0], in: state))
        XCTAssertThrowsError(try game.applyingRoll([.ace], to: state))

        state = try game.roll(state)
        XCTAssertThrowsError(try game.setHeldDice([5], in: state))
        state = try game.setHeldDice([0, 1, 2, 3, 4], in: state)
        XCTAssertThrowsError(try game.roll(state)) { error in
            XCTAssertEqual(error as? PokerDiceError, .noDiceToReroll)
        }
        state = try game.setHeldDice([0, 1, 2, 3], in: state)
        state = try game.roll(state)
        state = try game.roll(state)
        XCTAssertEqual(state[handFor: .playerOne].rollsUsed, 3)
        XCTAssertThrowsError(try game.roll(state))
        print("Invalid transitions and a fourth roll were rejected")
    }

    @MainActor
    func testSoloViewModelBlocksSkeletonAndResetsOnlyAfterStarting() async {
        print("Checking solo screen initial and reset states")
        let viewModel = PokerDiceViewModel(
            diceRoller: StubDiceRoller(rolls: [[.ace, .ace, .king, .queen, .nine]]),
            rollAnimationDuration: .zero
        )

        XCTAssertFalse(viewModel.canReset)
        XCTAssertFalse(viewModel.isDieEnabled(0))
        viewModel.resetGame()
        XCTAssertEqual(viewModel.playerHand.rollsUsed, 0)

        await viewModel.rollDice()
        XCTAssertTrue(viewModel.canReset)
        XCTAssertTrue(viewModel.isDieEnabled(0))
        viewModel.toggleHold(at: 0)
        XCTAssertTrue(viewModel.playerHand.heldDice.contains(0))
        viewModel.resetGame()
        XCTAssertFalse(viewModel.hasStarted)
        XCTAssertNil(viewModel.lastRollMessage)
        print("Skeleton dice stayed inert; holding and reset worked after the first roll")
    }

    @MainActor
    func testSoloViewModelBlocksControlsWhileRollingAndFinishesHand() async {
        print("Checking roll animation locks and solo hand completion")
        let viewModel = PokerDiceViewModel(
            diceRoller: StubDiceRoller(rolls: [
                [.ace, .ace, .king, .queen, .nine],
                [.ace, .ace, .king, .queen, .nine]
            ]),
            rollAnimationDuration: .zero
        )
        await viewModel.rollDice()
        XCTAssertTrue(viewModel.isDieEnabled(0))

        viewModel.finishHand()
        XCTAssertTrue(viewModel.isFinished)
        XCTAssertFalse(viewModel.canRoll)
        XCTAssertFalse(viewModel.isDieEnabled(0))
        XCTAssertTrue(viewModel.message.contains("One Pair"))
        print("Early finish showed the final hand and disabled further actions")
    }

    @MainActor
    func testSoloViewModelDisablesActionsDuringRoll() async {
        print("Checking controls are locked during an active roll")
        let viewModel = PokerDiceViewModel(
            diceRoller: StubDiceRoller(rolls: [
                [.ace, .ace, .king, .queen, .nine],
                [.ace, .ace, .king, .queen, .nine]
            ]),
            rollAnimationDuration: .milliseconds(100)
        )
        await viewModel.rollDice()
        XCTAssertTrue(viewModel.canReset)

        let nextRoll = Task { await viewModel.rollDice() }
        await Task.yield()
        XCTAssertTrue(viewModel.isRolling)
        XCTAssertFalse(viewModel.canRoll)
        XCTAssertFalse(viewModel.canReset)
        XCTAssertFalse(viewModel.isDieEnabled(0))

        await nextRoll.value
        XCTAssertFalse(viewModel.isRolling)
        print("Reroll, reset, and hold controls were blocked until rolling ended")
    }

    @MainActor
    func testSoloViewModelCompletesOnThirdRollAndBlocksAllHeldDice() async {
        print("Checking automatic completion after three rolls")
        let viewModel = PokerDiceViewModel(
            diceRoller: StubDiceRoller(rolls: [
                [.ace, .ace, .king, .queen, .nine],
                [.nine],
                [.nine]
            ]),
            rollAnimationDuration: .zero
        )

        await viewModel.rollDice()
        for index in 0..<5 {
            viewModel.toggleHold(at: index)
        }
        XCTAssertFalse(viewModel.canRoll)
        XCTAssertTrue(viewModel.canFinish)

        viewModel.toggleHold(at: 0)
        await viewModel.rollDice()
        await viewModel.rollDice()

        XCTAssertEqual(viewModel.playerHand.rollsUsed, 3)
        XCTAssertTrue(viewModel.isFinished)
        XCTAssertFalse(viewModel.canRoll)
        XCTAssertTrue(viewModel.message.contains("One Pair"))
        print("Third roll finalized the hand and showed its category")
    }
}

private final class StubDiceRoller: DiceRolling {
    private var rolls: [[DieFace]]

    init(rolls: [[DieFace]]) {
        self.rolls = rolls
    }

    func rollDice(count: Int) -> [DieFace] {
        guard !rolls.isEmpty else {
            XCTFail("No deterministic roll was supplied")
            return []
        }
        let nextRoll = rolls.removeFirst()
        guard nextRoll.count == count else {
            XCTFail("Expected \(count) dice, received \(nextRoll.count)")
            return []
        }
        return nextRoll
    }
}
