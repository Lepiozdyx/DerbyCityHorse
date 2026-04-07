//
//  NavigationManager.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import SwiftUI

class NavigationManager: ObservableObject {
    @Published var selectedTab: Int = 0
    
    func navigateToTab(_ tab: Int) {
        selectedTab = tab
    }
    
    func navigateToHorses() {
        selectedTab = 0
    }
    
    func navigateToCalendar() {
        selectedTab = 1
    }
    
    func navigateToTrainings() {
        selectedTab = 2
    }
    
    func navigateToReminders() {
        selectedTab = 3
    }
}
