//
//  AddJournalEntryView.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import SwiftUI

struct AddJournalEntryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var dataManager = DataManager.shared
    
    let horse: Horse
    
    @State private var selectedAction: ActionType? = nil
    @State private var selectedDate: Date = {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 0
        components.minute = 0
        components.second = 0
        return calendar.date(from: components) ?? now
    }()
    @State private var showingDatePicker = false
    @State private var showingTimePicker = false
    @State private var hasTimeSet: Bool = false
    @State private var showingActionPicker = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header
                CustomHeaderView(title: "Add Entry", onBack: {
                    dismiss()
                })
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Action Section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Action:")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                .padding(.bottom, 8)
                            
                            ZStack(alignment: .topTrailing) {
                                // Контейнер выбора действия
                                VStack(alignment: .leading, spacing: 0) {
                                    if showingActionPicker {
                                        VStack(alignment: .leading, spacing: 0) {
                                            // "Select" текст вверху
                                            HStack {
                                                Text("Select")
                                                    .font(.system(size: 14, weight: .regular))
                                                    .foregroundColor(Color(red: 0.627, green: 0.627, blue: 0.627)) // #A0A0A0
                                                Spacer()
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.top, 12)
                                            .padding(.bottom, 12)
                                            
                                            // Список действий
                                            VStack(alignment: .leading, spacing: 12) {
                                                ForEach(ActionType.allCases, id: \.self) { action in
                                                    Button(action: {
                                                        playButtonSound()
                                                        selectedAction = action
                                                        showingActionPicker = false
                                                    }) {
                                                        HStack {
                                                            Text("\(action.emoji) \(action.displayName)")
                                                                .font(.system(size: 14, weight: .regular))
                                                                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                                            Spacer()
                                                        }
                                                        .padding(.horizontal, 12)
                                                        .frame(height: 17)
                                                    }
                                                }
                                            }
                                            .padding(.bottom, 12)
                                        }
                                    } else {
                                        // Выбранное действие или "Select"
                                        HStack {
                                            if let action = selectedAction {
                                                Text("\(action.emoji) \(action.displayName)")
                                                    .font(.system(size: 14, weight: .regular))
                                                    .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                            } else {
                                                Text("Select")
                                                    .font(.system(size: 14, weight: .regular))
                                                    .foregroundColor(Color(red: 0.627, green: 0.627, blue: 0.627)) // #A0A0A0
                                            }
                                            Spacer()
                                            
                                            // Стрелка вниз (chevron)
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 10, weight: .regular))
                                                .foregroundColor(Color(red: 0.627, green: 0.627, blue: 0.627)) // #A0A0A0
                                        }
                                        .padding(.horizontal, 12)
                                        .frame(height: 30)
                                    }
                                }
                                .frame(width: 358)
                                .background(Color(red: 0.922, green: 0.922, blue: 0.922)) // #EBEBEB
                                .cornerRadius(8)
                                .layoutPriority(showingActionPicker ? 0 : 1)
                                
                                // Кнопка назад (стрелка) справа вверху
                                if showingActionPicker {
                                    Button(action: {
                                        playButtonSound()
                                        showingActionPicker = false
                                    }) {
                                        TriangleShape()
                                            .stroke(Color(red: 0.627, green: 0.627, blue: 0.627), lineWidth: 1) // #A0A0A0
                                            .frame(width: 5, height: 10)
                                            .rotationEffect(.degrees(45))
                                    }
                                    .padding(.trailing, 33)
                                    .padding(.top, 12)
                                }
                            }
                            .onTapGesture {
                                playButtonSound()
                                if !showingActionPicker {
                                    showingActionPicker = true
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Date Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date:")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                            
                            // Date Field
                            Button(action: {
                                playButtonSound()
                                showingDatePicker = true
                            }) {
                                HStack {
                                    Text(formatDate(selectedDate))
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                    
                                    Spacer()
                                    
                                    Image("t-1")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)
                                }
                                .padding(.horizontal, 12)
                                .frame(width: 358, height: 30)
                                .background(Color(red: 0.922, green: 0.922, blue: 0.922)) // #EBEBEB
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Time Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Time:")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                            
                            // Time Field
                            Button(action: {
                                playButtonSound()
                                showingTimePicker = true
                            }) {
                                HStack {
                                    Text(formatTime(selectedDate))
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(hasTimeSet ? Color(red: 0.133, green: 0.133, blue: 0.133) : Color(red: 0.627, green: 0.627, blue: 0.627)) // Черный если время выбрано, иначе серый
                                    
                                    Spacer()
                                    
                                    Image("t-2")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)
                                }
                                .padding(.horizontal, 12)
                                .frame(width: 358, height: 30)
                                .background(Color(red: 0.922, green: 0.922, blue: 0.922)) // #EBEBEB
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 100) // Отступ для кнопки внизу
                    }
                }
            }
            .overlay(alignment: .bottom) {
                // Save Button - зафиксирована внизу, выше панели навигации
                Button(action: {
                    playButtonSound()
                    guard let action = selectedAction else { return }
                    let entry = JournalEntry(
                        horseId: horse.id,
                        actionType: action,
                        date: selectedDate
                    )
                    dataManager.addJournalEntry(entry)
                    dismiss()
                }) {
                    Text("Save Entry")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 358, height: 50)
                        .background((hasTimeSet && selectedAction != nil) ? Color(red: 0.945, green: 0.0, blue: 0.173) : Color(red: 0.627, green: 0.627, blue: 0.627)) // Красный если время и действие выбраны, иначе серый
                        .cornerRadius(50)
                }
                .disabled(selectedAction == nil || !hasTimeSet)
                .padding(.horizontal, 16)
                .padding(.bottom, 99) // Отступ для панели навигации
            }
            .overlay(Group {
                if showingDatePicker {
                    DatePickerBottomSheet(selectedDate: $selectedDate, isPresented: $showingDatePicker)
                }
            })
            .overlay(Group {
                if showingTimePicker {
                    TimePickerBottomSheet(selectedDate: $selectedDate, isPresented: $showingTimePicker, onTimeSet: {
                        hasTimeSet = true
                    })
                }
            })
            .overlay(alignment: .bottom) {
                // Custom Tab Bar - скрывается при открытии пикеров
                if !showingDatePicker && !showingTimePicker {
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
            }
            
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
