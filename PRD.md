# Poker Dice — Product Requirements Document

## 1. Overview

Poker Dice is a digital version of the classic five-dice poker game. Players roll dice whose faces represent the values 9, 10, Jack, Queen, King, and Ace, keep the dice they want, and reroll the rest to make the strongest poker-style hand.

This document defines the rules and a small, testable first version of the game. Where Poker Dice has house-rule variations, this PRD uses the rules below as the product's canonical ruleset.

## 2. Product goal

Deliver a clear, fair, and enjoyable single-player Poker Dice game that:

- Explains the rules without requiring prior knowledge of the game.
- Lets players roll, hold, and reroll dice with understandable feedback.
- Evaluates every possible hand consistently.
- Makes the hand result easy to understand.

## 3. MVP scope

- One local, single-player Poker Dice hand at a time.
- The player gets up to three total rolls to make their best hand.
- The player can hold any dice between rolls, finish early, or play all three rolls.
- The game shows the final poker hand category; it does not compare the hand against an opponent.
- The player can start another hand after the current hand has started or finished.

Multiplayer, accounts, tournaments, statistics, configurable house rules, and play against a computer are out of scope for the MVP.

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

### 4.4 Evaluating the player's hand

- Evaluate the five dice using the hand ranking in Section 4.3.
- The hand category and its comparison values follow the ordering in Section 4.3; solo play does not compare the hand against an opponent.
- Show the current hand category after a roll and the final hand category when the player finishes.

### 4.5 Completing a solo hand

- The player may finish after any roll.
- The hand completes automatically after the third roll.
- Once complete, dice cannot be held or rerolled until a new hand is started.

## 5. Gameplay flow

1. **Start:** Show the game title and a clear action to roll the dice. The first roll starts the hand.
2. **Roll:** Roll all five dice on the first roll. On subsequent rolls, roll only dice that are not held.
3. **Hold selection:** Let the player toggle each die between held and rerolling. Clearly distinguish held dice.
4. **Continue or finish:** Show the number of rolls used and remaining. Allow another roll when eligible; allow the player to finish early.
5. **Result:** Show the final hand and its category when the player finishes or uses all three rolls.
6. **Replay:** Allow reset only after a hand has started. Resetting clears dice, held states, roll count, and result.

## 6. Functional requirements

### Game engine

- Represent a die face using a type-safe value with the canonical 9-to-Ace ordering.
- Generate five dice on the initial roll.
- Reroll only unheld dice on later rolls.
- Enforce a maximum of three rolls per player hand.
- Evaluate a five-die hand into exactly one hand category and its comparison values.
- Keep game state transitions valid: a player cannot reroll a completed hand.
- Keep randomness separate enough from hand evaluation and turn-state logic that tests can provide controlled rolls.

### User experience

- Make it clear how many rolls have been used, which dice are held, and what the current hand is.
- Do not allow a reroll when all dice are held or the hand is complete.
- Provide accessible labels for dice and hold state; do not rely on color alone to communicate selection.
- Clearly explain the final hand category.
- Reset must be unavailable before the first roll and while dice are rolling.
- Starting a new hand must not retain state from the previous game.

## 7. Quality requirements

- Identical dice values must always produce the same hand ranking.
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

### Turn and game-state tests

- A new hand starts with five skeleton dice and zero rolls used.
- The first roll reveals and rolls all five dice.
- A later roll changes only unheld dice and preserves held dice.
- A player can hold any number of dice, including zero and five.
- A player cannot exceed three rolls.
- Holding all dice prevents another roll.
- Early finish completes the current hand and prevents more rolls.
- The result appears after the third roll or an early finish.
- Starting a new game resets dice, held states, roll count, and result.

### UI and interaction tests

- The roll count is displayed and updated after each roll.
- Tapping a die toggles its held state and the state is visibly accessible.
- The roll action is disabled when no dice can be rerolled or the hand is complete.
- Dice cannot be held before the first roll, while rolling, or after the hand is complete.
- Reset is disabled before a hand starts and while dice are rolling.
- The result shows the final dice and their category.
- The replay action begins a clean game.

### Randomness and regression tests

- Injected/deterministic dice results produce the expected hand category.
- Random rolls always produce five valid faces, each in the 9-to-Ace set.
- Repeated evaluation of the same hand returns the same category and tie-break values.

## 9. Acceptance criteria

- A player can complete a turn using one, two, or three rolls.
- Held dice are preserved while unheld dice are rerolled.
- The game supports the full canonical ranking, including five of a kind and both straights.
- A solo hand ends after no more than three rolls and shows the correct hand category.
- A new game starts without state carried over from the previous one.
- The engine's core rules are covered by unit tests before release.

## 10. Open implementation notes

- The PRD defines rules and behavior, not a required visual design or animation style.
- If a later version adds variants (such as different dice faces, roll limits, or scoring across multiple rounds), those options should be explicitly named and must not silently change the canonical rules above.
