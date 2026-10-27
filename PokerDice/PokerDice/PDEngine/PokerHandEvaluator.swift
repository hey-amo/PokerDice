import Foundation

public struct PokerHandEvaluator: HandEvaluating {
    public init() {}

    public func evaluate(_ dice: [DieFace]) throws -> PokerHand {
        guard dice.count == 5 else {
            throw PokerDiceError.incorrectDiceCount(expected: 5, actual: dice.count)
        }

        let groupedFaces = Dictionary(grouping: dice, by: { $0 })
            .map { (face: $0.key, count: $0.value.count) }
            .sorted {
                if $0.count != $1.count {
                    return $0.count > $1.count
                }
                return $0.face > $1.face
            }

        if groupedFaces[0].count == 5 {
            return PokerHand(category: .fiveOfAKind, tieBreakers: [groupedFaces[0].face])
        }
        if groupedFaces[0].count == 4 {
            return PokerHand(category: .fourOfAKind, tieBreakers: [groupedFaces[0].face])
        }
        if groupedFaces[0].count == 3, groupedFaces[1].count == 2 {
            return PokerHand(
                category: .fullHouse,
                tieBreakers: [groupedFaces[0].face, groupedFaces[1].face]
            )
        }
        if let straightHighFace = straightHighFace(for: dice) {
            return PokerHand(category: .straight, tieBreakers: [straightHighFace])
        }
        if groupedFaces[0].count == 3 {
            return PokerHand(category: .threeOfAKind, tieBreakers: [groupedFaces[0].face])
        }
        if groupedFaces[0].count == 2, groupedFaces[1].count == 2 {
            let pairs = groupedFaces.prefix(2).map(\.face).sorted(by: >)
            let kicker = groupedFaces[2].face
            return PokerHand(category: .twoPair, tieBreakers: pairs + [kicker])
        }
        if groupedFaces[0].count == 2 {
            let pair = groupedFaces[0].face
            let kickers = groupedFaces.dropFirst().map(\.face).sorted(by: >)
            return PokerHand(category: .onePair, tieBreakers: [pair] + kickers)
        }

        return PokerHand(category: .highCard, tieBreakers: dice.sorted(by: >))
    }

    public func compare(_ lhs: PokerHand, _ rhs: PokerHand) -> ComparisonResult {
        if lhs.category != rhs.category {
            return lhs.category > rhs.category ? .orderedDescending : .orderedAscending
        }

        for (left, right) in zip(lhs.tieBreakers, rhs.tieBreakers) where left != right {
            return left > right ? .orderedDescending : .orderedAscending
        }
        return .orderedSame
    }

    private func straightHighFace(for dice: [DieFace]) -> DieFace? {
        let faces = Set(dice)
        guard faces.count == 5 else {
            return nil
        }

        if faces == Set([.nine, .ten, .jack, .queen, .king]) {
            return .king
        }
        if faces == Set([.ten, .jack, .queen, .king, .ace]) {
            return .ace
        }
        return nil
    }
}
