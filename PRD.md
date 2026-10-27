# Poker Dice — Product Requirements Document

## 1. Overview

Poker Dice is a digital version of the classic five-dice poker game. Players roll dice whose faces represent the values 9, 10, Jack, Queen, King, and Ace, keep the dice they want, and reroll the rest to make the strongest poker-style hand.

This document defines the rules and a small, testable first version of the game. Where Poker Dice has house-rule variations, this PRD uses the rules below as the product's canonical ruleset.

## 2. Product goal

Deliver a clear, fair, and enjoyable Poker Dice game that:

- Explains the rules without requiring prior knowledge of the game.
- Lets players roll, hold, and reroll dice with understandable feedback.
- Evaluates every possible hand consistently.
- Makes the outcome and winner of a game easy to understand.

## 3. MVP scope

- One-device, local pass-and-play for two players.
- A game consists of one hand for each player; each player gets up to three total rolls.
- Players take turns privately managing their own hand.
- The game compares the completed hands and declares a winner or a draw.
- Players can start a new game after the result.

Online play, accounts, tournaments, statistics, configurable house rules, and play against a computer are out of scope for the MVP.

## 4. Rules of Poker Dice

### 4.1 Dice and faces

- Each hand uses five six-sided dice.
- The six faces are 9, 10, Jack, Queen, King, and Ace.
- For comparisons, their values are ordered: 9 < 10 < Jack < Queen < King < Ace.
- A roll produces one face for each die.

### 4.2 A player's turn

1. The player rolls all five dice.
2. The player may keep any number of dice, including none or all five.
3. The player rerolls any dice not kept.
4. The player may keep and reroll again after the second roll.
5. The player's hand is final after the third roll, or earlier if the player chooses to stop.

There are at most three rolls per hand. A kept die retains its value and is not rolled again unless the player changes their selection before a later roll. Choosing to keep all five ends the turn because there are no dice left to reroll.

### 4.3 Hand rankings

Hands are ranked from strongest to weakest:

1. **Five of a kind** — all five dice show the same face.
2. **Four of a kind** — four dice show the same face.
3. **Full house** — three dice show one face and two show another.
4. **Straight** — all five faces are distinct and form one of the two sequences:
   - 9, 10, Jack, Queen, King
   - 10, Jack, Queen, King, Ace
5. **Three of a kind** — exactly three dice show the same face.
6. **Two pair** — two dice show one face, two show another, and the fifth die is different.
7. **One pair** — exactly two dice show the same face.
8. **High card** — none of the combinations above; compare the dice from highest to lowest.

Five of a kind is possible because each die has the same six faces. There are no wraparound straights (for example, Ace-9-10-Jack-Queen is not a straight).

### 4.4 Comparing hands and deciding a winner

- A higher-ranked hand always beats a lower-ranked hand.
- If hands have the same rank, compare the values that define that hand, highest first:
  - Four/three/five of a kind: value of the matching group.
  - Full house: value of the three-of-a-kind, then the pair.
  - Straight: value of its highest die.
  - Two pair: higher pair, lower pair, then the remaining die.
  - One pair: pair, then the remaining dice in descending order.
  - High card: all five dice in descending order.
- If every comparison value is equal, the hands tie. The game declares a draw; neither player wins the hand.

### 4.5 Between players

- Player 1 completes and confirms their hand before Player 2 begins.
- The game should avoid exposing Player 1's final dice to Player 2 during Player 2's turn (for example, by showing a handoff screen).
- Once both hands are final, show both hands, their ranked descriptions, and the winner or draw.

## 5. Gameplay flow

1. **Start:** Show the game title and a clear action to start a two-player game.
2. **Player handoff:** Identify whose turn it is and provide a handoff before showing that player's dice.
3. **Roll:** Roll all five dice on the first roll. On subsequent rolls, roll only dice that are not held.
4. **Hold selection:** Let the player toggle each die between held and rerolling. Clearly distinguish held dice.
5. **Continue or finish:** Show the number of rolls used and remaining. Allow another roll when eligible; allow the player to finish early if desired.
6. **Confirm hand:** Once the turn ends, show the player's final hand and pass control to the next player.
7. **Result:** After both turns, show each player's hand, hand rank, and the outcome.
8. **Replay:** Offer a new game that resets all dice, held states, roll counts, and result state.

## 6. Functional requirements

### Game engine

- Represent a die face using a type-safe value with the canonical 9-to-Ace ordering.
- Generate five dice on the initial roll.
- Reroll only unheld dice on later rolls.
- Enforce a maximum of three rolls per player hand.
- Evaluate a five-die hand into exactly one hand category and its comparison values.
- Compare hands according to the ranking and tie-break rules in Section 4.
- Keep game state transitions valid: a player cannot reroll a completed hand or act out of turn.
- Keep randomness separate enough from hand evaluation and turn-state logic that tests can provide controlled rolls.

### User experience

- Make it clear which player is active, which dice are held, and how many rolls remain.
- Do not allow a reroll when all dice are held or the hand is complete.
- Provide accessible labels for dice and hold state; do not rely on color alone to communicate selection.
- Clearly explain the final hand category and comparison result.
- Starting a new game must not retain state from the previous game.

## 7. Quality requirements

- Identical game states and dice values must always produce identical hand rankings and outcomes.
- The interface must remain usable with VoiceOver and standard Dynamic Type settings.
- Dice controls and game actions must have clear labels and visible state.
- The game should not require a network connection.

## 8. Tests to write

Tests below describe required coverage; they are not a claim that these tests already exist.

### Hand evaluation unit tests

- Each of the eight hand categories is recognized correctly.
- Five of a kind is recognized and ranks above four of a kind.
- A full house is not mistaken for three of a kind or two pair.
- Both valid straights are recognized, including the 10-to-Ace straight as the higher straight.
- Unordered dice values still produce the correct category.
- Repeated values prevent a hand from being classified as a straight.
- Invalid or incomplete hand input is rejected or handled according to the engine's chosen validation contract.

### Hand comparison unit tests

- Every category beats each category below it in the ranking.
- Same-category hands use the specified tie-break values.
- Pair and two-pair kickers are compared in the correct order.
- A lower-ranked hand never wins due to a larger individual die.
- Equal comparison values produce a draw.

### Turn and game-state tests

- A new hand starts with five dice and zero rolls used.
- The first roll rolls all five dice.
- A later roll changes only unheld dice and preserves held dice.
- A player can hold any number of dice, including zero and five.
- A player cannot exceed three rolls.
- Holding all dice prevents another roll.
- Ending early finalizes the current hand.
- Player 2 cannot act before Player 1 completes their hand.
- The result is not available until both players' hands are final.
- Starting a new game resets both players, dice, held states, roll counts, and result.

### UI and interaction tests

- The correct active player and roll count are displayed.
- Tapping a die toggles its held state and the state is visibly accessible.
- The roll action is disabled when no dice can be rerolled or the hand is complete.
- The handoff screen appears between players and before revealing the next player's dice.
- The result screen shows both final hands, their categories, and the correct outcome for win, loss, and draw.
- The replay action begins a clean game.

### Randomness and regression tests

- Injected/deterministic dice results produce the expected hand and game result.
- Random rolls always produce five valid faces, each in the 9-to-Ace set.
- Repeated evaluation of the same hand returns the same category and comparison values.

## 9. Acceptance criteria

- A player can complete a turn using one, two, or three rolls.
- Held dice are preserved while unheld dice are rerolled.
- The game supports the full canonical ranking, including five of a kind and both straights.
- Hand comparisons follow all specified tie-breakers and correctly identify draws.
- A complete two-player game ends with a clear, correct result.
- A new game starts without state carried over from the previous one.
- The engine's core rules are covered by unit tests before release.

## 10. Open implementation notes

- The PRD defines rules and behavior, not a required visual design or animation style.
- If a later version adds variants (such as different dice faces, roll limits, or scoring across multiple rounds), those options should be explicitly named and must not silently change the canonical rules above.
