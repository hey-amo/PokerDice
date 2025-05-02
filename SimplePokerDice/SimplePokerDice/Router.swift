//
//  Router.swift
//  SimplePokerDice
//
//  Created by Amarjit on 02/05/2025.
//

import SwiftUI

enum Page: Int, Identifiable {
    case mainMenu, game
    
    var id: Int { self.rawValue }
    
    var title: String {
        switch self {
        case .mainMenu: return "Main Menu"
        case .game: return "Game"
        }
    }
}

enum Modal: Identifiable {
    case settings
    
    var id: String {
        switch self {
        case .settings: return "settings"
        }
    }
}

class Router: ObservableObject {
    @Published var currentPage: Page = .mainMenu
    @Published var activeModal: Modal?
    @Published var isAnimating: Bool = false
    
    static let shared = Router()
    
    private init() {}
    
    // Navigation methods
    func navigate(to page: Page) {
        // Don't navigate if animations are playing
        guard !isAnimating else { return }
        
        withAnimation {
            currentPage = page
        }
    }
    
    func goBack() {
        // Logic for going back to previous page
        // For now, just go to main menu
        navigate(to: .mainMenu)
    }
    
    // Modal methods
    func showModal(_ modal: Modal) {
        // Don't show modal if animations are playing
        guard !isAnimating else { return }
        activeModal = modal
    }
    
    func dismissModal() {
        activeModal = nil
    }
}

