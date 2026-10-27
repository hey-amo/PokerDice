import Combine
import Foundation

@MainActor
final class PokerDiceViewModel: ObservableObject {
    @Published private(set) var gameState = GameState()
    @Published private(set) var isRolling = false
    @Published private(set) var isFinished = false
    @Published private(set) var message = "Tap Roll Dice to start your hand."
    @Published private(set) var lastRollMessage: String?

    private let game: PokerDiceGame
    private let evaluator: any HandEvaluating
    private let rollAnimationDuration: Duration

    init(
        diceRoller: any DiceRolling = RandomDiceRoller(),
        evaluator: any HandEvaluating = PokerHandEvaluator(),
        rollAnimationDuration: Duration = .milliseconds(650)
    ) {
        game = PokerDiceGame(diceRoller: diceRoller, handEvaluator: evaluator)
        self.evaluator = evaluator
        self.rollAnimationDuration = rollAnimationDuration
    }

    var playerHand: PlayerHand {
        gameState[handFor: .playerOne]
    }

    var hasStarted: Bool {
        playerHand.rollsUsed > 0
    }

    var canRoll: Bool {
        guard !isRolling, !isFinished, playerHand.rollsUsed < 3 else {
            return false
        }
        return !hasStarted || playerHand.heldDice.count < playerHand.dice.count
    }

    var canReset: Bool {
        hasStarted && !isRolling
    }

    var canFinish: Bool {
        hasStarted && !isRolling && !isFinished
    }

    func isDieEnabled(_ index: Int) -> Bool {
        !isRolling && !isFinished && hasStarted && playerHand.dice.indices.contains(index)
    }

    func rollDice() async {
        guard canRoll else {
            return
        }

        let startingState = hasStarted ? gameState : game.startNewGame()
        let startingHand = startingState[handFor: .playerOne]
        isRolling = true
        message = "Rolling dice…"
        defer { isRolling = false }

        do {
            try await Task.sleep(for: rollAnimationDuration)
            try Task.checkCancellation()

            let updatedState = try game.roll(startingState)
            let updatedHand = updatedState[handFor: .playerOne]
            let rolledFaces = updatedHand.dice.enumerated().compactMap { index, face in
                startingHand.rollsUsed == 0 || !startingHand.heldDice.contains(index) ? face : nil
            }
            let evaluatedHand = try evaluator.evaluate(updatedHand.dice)

            gameState = updatedState
            lastRollMessage = "Rolled: " + rolledFaces.map(\.displayName).joined(separator: " · ")

            if updatedHand.rollsUsed == 3 {
                isFinished = true
                message = "Final hand: \(evaluatedHand.category.displayName)"
            } else {
                message = "Current hand: \(evaluatedHand.category.displayName)"
            }
        } catch is CancellationError {
            message = "Roll cancelled. Tap Roll Dice to try again."
        } catch {
            message = "Unable to roll the dice: \(error.localizedDescription)"
        }
    }

    func toggleHold(at index: Int) {
        guard isDieEnabled(index) else {
            return
        }

        do {
            gameState = try game.toggleHeldDie(index, in: gameState)
            if playerHand.heldDice.count == playerHand.dice.count {
                message = "All dice held. Unlock a die to reroll, or finish your hand."
            } else if isFinished == false, playerHand.rollsUsed < 3 {
                message = "Choose dice to hold, then roll again."
            }
        } catch {
            message = "Unable to change hold: \(error.localizedDescription)"
        }
    }

    func finishHand() {
        guard canFinish else {
            return
        }

        do {
            let hand = try evaluator.evaluate(playerHand.dice)
            isFinished = true
            message = "Final hand: \(hand.category.displayName)"
        } catch {
            message = "Unable to evaluate the hand: \(error.localizedDescription)"
        }
    }

    func resetGame() {
        guard canReset else {
            return
        }

        gameState = GameState()
        isFinished = false
        lastRollMessage = nil
        message = "Tap Roll Dice to start your hand."
    }
}
