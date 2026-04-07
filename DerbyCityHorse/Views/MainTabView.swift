//
//  MainTabView.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var dataManager = DataManager.shared
    @State private var showingAddHorse = false
    
    private var selectedTab: Int {
        navigationManager.selectedTab
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Контент
            if selectedTab == 0 {
                HorsesListView()
                    .environmentObject(navigationManager)
            } else if selectedTab == 1 {
                CalendarView()
                    .environmentObject(navigationManager)
            } else if selectedTab == 2 {
                TrainingsListView()
                    .environmentObject(navigationManager)
            } else {
                RemindersView()
                    .environmentObject(navigationManager)
            }
            
            // Кнопка добавления лошади (только для экрана списка лошадей)
            if selectedTab == 0 {
                Button(action: {
                    playButtonSound()
                    showingAddHorse = true
                }) {
                    Text("Add Horse")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 358, height: 50)
                        .background(Color(red: 0.945, green: 0.0, blue: 0.173)) // #F1002C
                        .cornerRadius(50)
                }
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
            
            // Custom Tab Bar
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    TabBarButton(
                        inactiveImage: "m-1-1",
                        activeImage: "m-1-2",
                        title: "Horses",
                        isSelected: selectedTab == 0 // Изначально selectedTab = 0, поэтому isSelected = true и используется m-1-2
                    ) {
                        navigationManager.navigateToHorses()
                    }
                    
                    TabBarButton(
                        inactiveImage: "m-2-1",
                        activeImage: "m-2-2",
                        title: "Calendar",
                        isSelected: selectedTab == 1
                    ) {
                        navigationManager.navigateToCalendar()
                    }
                    
                    TabBarButton(
                        inactiveImage: "m-3-1",
                        activeImage: "m-3-2",
                        title: "Trainings",
                        isSelected: selectedTab == 2
                    ) {
                        navigationManager.navigateToTrainings()
                    }
                    
                    TabBarButton(
                        inactiveImage: "m-4-1",
                        activeImage: "m-4-2",
                        title: "Reminders",
                        isSelected: selectedTab == 3
                    ) {
                        navigationManager.navigateToReminders()
                    }
                }
                .frame(height: 83)
                .background(Color(red: 0.92, green: 0.92, blue: 0.92)) // #EBEBEB
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .fullScreenCover(isPresented: $showingAddHorse) {
            AddEditHorseView(horse: nil)
                .environmentObject(navigationManager)
        }
    }
}

struct TabBarButton: View {
    let inactiveImage: String
    let activeImage: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            playButtonSound()
            action()
        }) {
            VStack(spacing: 4) {
                // Для выбранной вкладки используем activeImage (с окончанием "2"), для остальных - inactiveImage (с окончанием "1")
                Group {
                    if isSelected {
                        Image(activeImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)
                    } else {
                        Image(inactiveImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)
                    }
                }
                
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(NavigationManager())
}
