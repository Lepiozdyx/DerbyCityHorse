//
//  HorseDetailView.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import SwiftUI

struct HorseDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var dataManager = DataManager.shared
    
    let horse: Horse
    
    @State private var selectedTab: TabType = .journal
    @State private var showingAddEntry = false
    
    enum TabType {
        case journal
        case trainings
    }
    
    var journalEntries: [JournalEntry] {
        dataManager.getJournalEntries(for: horse.id)
    }
    
    var trainings: [Training] {
        dataManager.getTrainings(for: horse.id)
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header
                CustomHeaderView(title: horse.name, onBack: {
                    dismiss()
                })
                
                // Horse Profile Section
                HStack(spacing: 16) {
                        // Photo - 150x150px, border-radius 16px
                        if let photo = horse.photo {
                            photo
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 150, height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(red: 0.945, green: 0.0, blue: 0.173), lineWidth: 1)
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .frame(width: 150, height: 150)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(red: 0.945, green: 0.0, blue: 0.173), lineWidth: 1)
                                )
                        }
                        
                        // Info Section
                        VStack(alignment: .leading, spacing: 4) {
                            Text(horse.name)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 0.945, green: 0.0, blue: 0.173)) // #F1002C
                            
                            Text(horse.breed)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                            
                            Text(formatDate(horse.dateOfBirth))
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                        }
                        
                        Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
                
                // Divider Line - Gradient
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.945, green: 0.0, blue: 0.173).opacity(0),
                                Color(red: 0.945, green: 0.0, blue: 0.173),
                                Color(red: 0.945, green: 0.0, blue: 0.173).opacity(0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 358, height: 2)
                    .padding(.top, 8)
                
                // Tabs - 200x30px container
                HStack(spacing: 4) {
                    // Journal Tab - 98x28px
                    Button(action: {
                        playButtonSound()
                        selectedTab = .journal
                    }) {
                        Text("Journal")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(selectedTab == .journal ? .white : Color(red: 0.133, green: 0.133, blue: 0.133))
                            .frame(width: 98, height: 28)
                            .background(selectedTab == .journal ? Color(red: 0.945, green: 0.0, blue: 0.173) : Color.clear)
                            .cornerRadius(5)
                    }
                    
                    // Trainings Tab - 98x28px
                    Button(action: {
                        playButtonSound()
                        selectedTab = .trainings
                    }) {
                        Text("Trainings")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(selectedTab == .trainings ? .white : Color(red: 0.133, green: 0.133, blue: 0.133))
                            .frame(width: 98, height: 28)
                            .background(selectedTab == .trainings ? Color(red: 0.945, green: 0.0, blue: 0.173) : Color.clear)
                            .cornerRadius(5)
                    }
                }
                .frame(width: 200, height: 30)
                .background(Color.white)
                .cornerRadius(4)
                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 0)
                .padding(.top, 10)
                
                // Content
                if selectedTab == .journal {
                    journalView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    trainingsView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button(action: {
                    playButtonSound()
                    showingAddEntry = true
                }) {
                    Text(selectedTab == .journal ? "Add Entry" : "Add Training")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 188, height: 50)
                        .background(Color(red: 0.945, green: 0.0, blue: 0.173)) // #F1002C
                        .cornerRadius(50)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 99) // 83px для панели навигации + 16px отступ
            }
            .fullScreenCover(isPresented: $showingAddEntry) {
                if selectedTab == .journal {
                    AddJournalEntryView(horse: horse)
                        .environmentObject(navigationManager)
                } else {
                    AddTrainingView(horse: horse)
                        .environmentObject(navigationManager)
                }
            }
            
            // Custom Tab Bar - внизу экрана
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        TabBarButton(
                            inactiveImage: "m-1-1",
                            activeImage: "m-1-2",
                            title: "Horses",
                            isSelected: navigationManager.selectedTab == 0
                        ) {
                            navigationManager.navigateToHorses()
                            dismiss()
                        }
                        
                        TabBarButton(
                            inactiveImage: "m-2-1",
                            activeImage: "m-2-2",
                            title: "Calendar",
                            isSelected: navigationManager.selectedTab == 1
                        ) {
                            navigationManager.navigateToCalendar()
                            dismiss()
                        }
                        
                        TabBarButton(
                            inactiveImage: "m-3-1",
                            activeImage: "m-3-2",
                            title: "Trainings",
                            isSelected: navigationManager.selectedTab == 2
                        ) {
                            navigationManager.navigateToTrainings()
                            dismiss()
                        }
                        
                        TabBarButton(
                            inactiveImage: "m-4-1",
                            activeImage: "m-4-2",
                            title: "Reminders",
                            isSelected: navigationManager.selectedTab == 3
                        ) {
                            navigationManager.navigateToReminders()
                            dismiss()
                        }
                    }
                    .frame(height: 83)
                    .background(Color(red: 0.92, green: 0.92, blue: 0.92)) // #EBEBEB
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private var journalView: some View {
        Group {
            if journalEntries.isEmpty {
                VStack {
                    Spacer()
                        .frame(height: 100)
                    
                    VStack(spacing: 4) {
                        Text("No activity yet")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(red: 0.945, green: 0.0, blue: 0.173)) // #F1002C
                            .frame(width: 358)
                            .multilineTextAlignment(.center)
                        
                        Text("Start logging daily care for your horse")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                            .frame(width: 358)
                            .multilineTextAlignment(.center)
                            .lineSpacing(0)
                    }
                    .frame(width: 358, height: 57)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(groupedJournalEntries.keys.sorted(by: >), id: \.self) { month in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(month)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                
                                ForEach(groupedJournalEntries[month] ?? []) { entry in
                                    JournalEntryRow(entry: entry)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 80)
                }
            }
        }
    }
    
    private var trainingsView: some View {
        Group {
            if trainings.isEmpty {
                VStack {
                    Spacer()
                        .frame(height: 100)
                    
                    VStack(spacing: 16) {
                        Text("No trainings yet")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(red: 0.945, green: 0.0, blue: 0.173)) // #F1002C
                        
                        Text("Start tracking your horse workouts")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(trainings) { training in
                            TrainingCard(training: training)
                        }
                    }
                    .padding()
                    .padding(.bottom, 80)
                }
            }
        }
    }
    
    private var groupedJournalEntries: [String: [JournalEntry]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US")
        
        return Dictionary(grouping: journalEntries) { entry in
            formatter.string(from: entry.date)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
}


struct JournalEntryRow: View {
    let entry: JournalEntry
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }
    
    var body: some View {
        HStack {
            Text(entry.actionType.emoji)
                .font(.system(size: 20))
            
            Text(entry.actionType.displayName)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.945, green: 0.0, blue: 0.173)) // #F1002C
            
            Spacer()
            
            Text(dateFormatter.string(from: entry.date))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct TrainingCard: View {
    let training: Training
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(training.type.rawValue)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.red)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(training.duration) min")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                    
                    HStack(spacing: 4) {
                        Text(training.mood.rawValue)
                            .font(.system(size: 12))
                            .foregroundColor(.black)
                        Text(training.mood.emoji)
                            .font(.system(size: 14))
                    }
                }
            }
            
            Text(dateFormatter.string(from: training.date))
                .font(.system(size: 14))
                .foregroundColor(.black)
            
            Text(training.notes)
                .font(.system(size: 14))
                .foregroundColor(.black)
                .italic()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
