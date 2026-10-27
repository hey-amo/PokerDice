public struct PokerDiceGame {
    private let diceRoller: any DiceRolling
    private let handEvaluator: any HandEvaluating

    public init(
        diceRoller: any DiceRolling = RandomDiceRoller(),
        handEvaluator: any HandEvaluating = PokerHandEvaluator()
    ) {
        self.diceRoller = diceRoller
        self.handEvaluator = handEvaluator
    }

    public func startNewGame() -> GameState {
        GameState(phase: .playing(.playerOne))
    }

    public func setHeldDice(_ indices: Set<Int>, in state: GameState) throws -> GameState {
        guard case let .playing(player) = state.phase else {
            throw PokerDiceError.invalidGamePhase
        }
        let hand = state[handFor: player]
        guard hand.rollsUsed > 0, !hand.isComplete else {
            throw PokerDiceError.handNotStarted
        }
        guard indices.allSatisfy({ (0..<hand.dice.count).contains($0) }) else {
            throw PokerDiceError.invalidHeldDice
        }

        return replacingHand(
            for: player,
            with: PlayerHand(
                dice: hand.dice,
                heldDice: indices,
                rollsUsed: hand.rollsUsed,
                isComplete: hand.isComplete
            ),
            in: state
        )
    }

    public func toggleHeldDie(_ index: Int, in state: GameState) throws -> GameState {
        guard case let .playing(player) = state.phase else {
            throw PokerDiceError.invalidGamePhase
        }
        let hand = state[handFor: player]
        guard hand.rollsUsed > 0, !hand.isComplete else {
            throw PokerDiceError.handNotStarted
        }
        guard hand.dice.indices.contains(index) else {
            throw PokerDiceError.invalidDieIndex
        }

        var heldDice = hand.heldDice
        if !heldDice.insert(index).inserted {
            heldDice.remove(index)
        }
        return try setHeldDice(heldDice, in: state)
    }

    public func roll(_ state: GameState) throws -> GameState {
        let count = try numberOfDiceToRoll(in: state)
        let rolledDice = diceRoller.rollDice(count: count)
        guard rolledDice.count == count else {
            throw PokerDiceError.incorrectDiceCount(expected: count, actual: rolledDice.count)
        }
        return try applyingRoll(rolledDice, to: state)
    }

    public func applyingRoll(_ rolledDice: [DieFace], to state: GameState) throws -> GameState {
        guard case let .playing(player) = state.phase else {
            throw PokerDiceError.invalidGamePhase
        }
        let hand = state[handFor: player]
        guard !hand.isComplete else {
            throw PokerDiceError.invalidGamePhase
        }
        guard hand.rollsUsed < 3 else {
            throw PokerDiceError.maximumRollsReached
        }

        let diceToRoll = hand.rollsUsed == 0 ? 5 : hand.dice.count - hand.heldDice.count
        guard diceToRoll > 0 else {
            throw PokerDiceError.noDiceToReroll
        }
        guard rolledDice.count == diceToRoll else {
            throw PokerDiceError.incorrectDiceCount(expected: diceToRoll, actual: rolledDice.count)
        }

        var updatedDice = hand.dice
        if hand.rollsUsed == 0 {
            updatedDice = rolledDice
        } else {
            var rolledIndex = 0
            for index in updatedDice.indices where !hand.heldDice.contains(index) {
                updatedDice[index] = rolledDice[rolledIndex]
                rolledIndex += 1
            }
        }

        return replacingHand(
            for: player,
            with: PlayerHand(
                dice: updatedDice,
                heldDice: hand.heldDice,
                rollsUsed: hand.rollsUsed + 1
            ),
            in: state
        )
    }

    public func finishTurn(_ state: GameState) throws -> GameState {
        guard case let .playing(player) = state.phase else {
            throw PokerDiceError.invalidGamePhase
        }
        let hand = state[handFor: player]
        guard hand.rollsUsed > 0, !hand.isComplete else {
            throw PokerDiceError.handNotStarted
        }

        let completedHand = PlayerHand(
            dice: hand.dice,
            heldDice: hand.heldDice,
            rollsUsed: hand.rollsUsed,
            isComplete: true
        )
        let updatedState = replacingHand(for: player, with: completedHand, in: state)

        switch player {
        case .playerOne:
            return GameState(hands: updatedState.hands, phase: .awaitingHandoff(.playerTwo))
        case .playerTwo:
            let playerOneHand = try handEvaluator.evaluate(updatedState[handFor: .playerOne].dice)
            let playerTwoHand = try handEvaluator.evaluate(updatedState[handFor: .playerTwo].dice)
            let comparison = handEvaluator.compare(playerOneHand, playerTwoHand)
            let outcome: GameOutcome
            switch comparison {
            case .orderedAscending:
                outcome = .winner(.playerTwo)
            case .orderedDescending:
                outcome = .winner(.playerOne)
            case .orderedSame:
                outcome = .draw
            }
            return GameState(hands: updatedState.hands, phase: .finished(outcome))
        }
    }

    public func confirmHandoff(_ state: GameState) throws -> GameState {
        guard case let .awaitingHandoff(player) = state.phase else {
            throw PokerDiceError.invalidGamePhase
        }
        return GameState(hands: state.hands, phase: .playing(player))
    }

    private func numberOfDiceToRoll(in state: GameState) throws -> Int {
        guard case let .playing(player) = state.phase else {
            throw PokerDiceError.invalidGamePhase
        }
        let hand = state[handFor: player]
        guard !hand.isComplete else {
            throw PokerDiceError.invalidGamePhase
        }
        guard hand.rollsUsed < 3 else {
            throw PokerDiceError.maximumRollsReached
        }
        let count = hand.rollsUsed == 0 ? 5 : hand.dice.count - hand.heldDice.count
        guard count > 0 else {
            throw PokerDiceError.noDiceToReroll
        }
        return count
    }

    private func replacingHand(
        for player: PlayerID,
        with hand: PlayerHand,
        in state: GameState
    ) -> GameState {
        var hands = state.hands
        hands[player] = hand
        return GameState(hands: hands, phase: state.phase)
    }
}
