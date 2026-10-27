import Foundation

public enum DieFace: Int, CaseIterable, Comparable, Hashable, Sendable {
    case nine
    case ten
    case jack
    case queen
    case king
    case ace

    public static func < (lhs: DieFace, rhs: DieFace) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public var displayName: String {
        switch self {
        case .nine: "9"
        case .ten: "10"
        case .jack: "J"
        case .queen: "Q"
        case .king: "K"
        case .ace: "A"
        }
    }
}

public enum PlayerID: Int, CaseIterable, Comparable, Hashable, Sendable {
    case playerOne
    case playerTwo

    public static func < (lhs: PlayerID, rhs: PlayerID) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public var displayName: String {
        switch self {
        case .playerOne: "Player 1"
        case .playerTwo: "Player 2"
        }
    }

    public var next: PlayerID {
        self == .playerOne ? .playerTwo : .playerOne
    }
}

public enum HandCategory: Int, CaseIterable, Comparable, Sendable {
    case highCard
    case onePair
    case twoPair
    case threeOfAKind
    case straight
    case fullHouse
    case fourOfAKind
    case fiveOfAKind

    public static func < (lhs: HandCategory, rhs: HandCategory) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public var displayName: String {
        switch self {
        case .highCard: "High Card"
        case .onePair: "One Pair"
        case .twoPair: "Two Pair"
        case .threeOfAKind: "Three of a Kind"
        case .straight: "Straight"
        case .fullHouse: "Full House"
        case .fourOfAKind: "Four of a Kind"
        case .fiveOfAKind: "Five of a Kind"
        }
    }
}

public struct PokerHand: Equatable, Sendable {
    public let category: HandCategory
    public let tieBreakers: [DieFace]

    public init(category: HandCategory, tieBreakers: [DieFace]) {
        self.category = category
        self.tieBreakers = tieBreakers
    }
}

public struct PlayerHand: Equatable, Sendable {
    public let dice: [DieFace]
    public let heldDice: Set<Int>
    public let rollsUsed: Int
    public let isComplete: Bool

    public init(
        dice: [DieFace] = [],
        heldDice: Set<Int> = [],
        rollsUsed: Int = 0,
        isComplete: Bool = false
    ) {
        self.dice = dice
        self.heldDice = heldDice
        self.rollsUsed = rollsUsed
        self.isComplete = isComplete
    }
}

public enum GameOutcome: Equatable, Sendable {
    case draw
    case winner(PlayerID)
}

public enum GamePhase: Equatable, Sendable {
    case notStarted
    case playing(PlayerID)
    case awaitingHandoff(PlayerID)
    case finished(GameOutcome)
}

public struct GameState: Equatable, Sendable {
    public let hands: [PlayerID: PlayerHand]
    public let phase: GamePhase

    public init(
        hands: [PlayerID: PlayerHand] = Dictionary(
            uniqueKeysWithValues: PlayerID.allCases.map { ($0, PlayerHand()) }
        ),
        phase: GamePhase = .notStarted
    ) {
        self.hands = hands
        self.phase = phase
    }

    public subscript(handFor player: PlayerID) -> PlayerHand {
        hands[player, default: PlayerHand()]
    }
}

public enum PokerDiceError: Error, Equatable {
    case invalidGamePhase
    case handNotStarted
    case invalidDieIndex
    case invalidHeldDice
    case noDiceToReroll
    case maximumRollsReached
    case incorrectDiceCount(expected: Int, actual: Int)
}

public protocol DiceRolling {
    func rollDice(count: Int) -> [DieFace]
}

public protocol HandEvaluating {
    func evaluate(_ dice: [DieFace]) throws -> PokerHand
    func compare(_ lhs: PokerHand, _ rhs: PokerHand) -> ComparisonResult
}

public struct RandomDiceRoller: DiceRolling {
    public init() {}

    public func rollDice(count: Int) -> [DieFace] {
        let faces = DieFace.allCases
        return (0..<count).map { _ in faces[Int.random(in: faces.indices)] }
    }
}
