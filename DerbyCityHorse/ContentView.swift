//
//  ContentView.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var navigationManager = NavigationManager()
    
    var body: some View {
        MainTabView()
            .environmentObject(navigationManager)
    }
}

#Preview {
    ContentView()
}
