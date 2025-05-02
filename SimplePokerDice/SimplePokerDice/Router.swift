//
//  Router.swift
//  SimplePokerDice
//
//  Created by Amarjit on 02/05/2025.
//

import SwiftUI

enum Page: Int {
    case mainMenu, play
}

enum Modal: Identifiable {
    case settings
    case menu
    
    var id: String {
        switch self {
        case .settings: return "settings"
        case .menu: return "menu"
        }
    }
}

class Router: ObservableObject {
    @Published var activeModal: Modal?
    @Published var isAnimating: Bool = false
    
    static let shared = Router()
    
    private init() {}
    
    func showModal(_ modal: Modal) {
        // Don't show modal if animations are playing
        guard !isAnimating else { return }
        activeModal = modal
    }
    
    func dismissModal() {
        activeModal = nil
    }
}

