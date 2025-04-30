//
//  Die.swift
//  SimplePokerDice
//
//  Created by Amarjit on 23/04/2025.
//

import Foundation

struct Die: Identifiable {
    let id = UUID()
    var face: DiceFace
    var isHeld: Bool = false
}
