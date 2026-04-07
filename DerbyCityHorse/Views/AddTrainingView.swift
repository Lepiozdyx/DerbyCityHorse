//
//  AddTrainingView.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import SwiftUI

struct AddTrainingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var dataManager = DataManager.shared
    
    let horse: Horse?
    let training: Training?
    
    @State private var selectedHorse: Horse?
    @State private var selectedType: TrainingType
    @State private var date: Date
    @State private var time: Date
    @State private var duration: String
    @State private var notes: String
    @State private var selectedMood: Mood?
    @State private var showingDatePicker = false
    @State private var showingTimePicker = false
    @State private var hasTimeSet: Bool = false
    @State private var showingMoodPicker = false
    @State private var showingHorsePicker = false
    @State private var showingTypePicker = false
    
    init(horse: Horse? = nil, training: Training? = nil) {
        self.horse = horse
        self.training = training
        
        if let training = training {
            _selectedType = State(initialValue: training.type)
            _date = State(initialValue: training.date)
            _time = State(initialValue: training.date)
            _duration = State(initialValue: String(training.duration))
            _notes = State(initialValue: training.notes)
            _selectedMood = State(initialValue: training.mood)
            _selectedHorse = State(initialValue: dataManager.horses.first(where: { $0.id == training.horseId }))
            _hasTimeSet = State(initialValue: true)
        } else {
            _selectedType = State(initialValue: .warmup)
            let now = Date()
            _date = State(initialValue: now)
            _time = State(initialValue: {
                let calendar = Calendar.current
                var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
                components.hour = 0
                components.minute = 0
                return calendar.date(from: components) ?? now
            }())
            _duration = State(initialValue: "")
            _notes = State(initialValue: "")
            _selectedMood = State(initialValue: nil)
            _selectedHorse = State(initialValue: horse)
        }
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header with back button
                HStack(spacing: 8) {
                    Button(action: {
                        playButtonSound()
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                            .frame(width: 7, height: 14)
                    }
                    
                    Text(training == nil ? "Add Training" : "Edit Training")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                }
                .frame(height: 44)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Horse Section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Horse:")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                .padding(.bottom, 8)
                            
                            ZStack(alignment: .topTrailing) {
                                // Контейнер выбора лошади
                                VStack(alignment: .leading, spacing: 0) {
                                    if showingHorsePicker {
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
                                            
                                            // Список лошадей
                                            VStack(alignment: .leading, spacing: 12) {
                                                ForEach(dataManager.horses) { horse in
                                                    Button(action: {
                                                        playButtonSound()
                                                        selectedHorse = horse
                                                        showingHorsePicker = false
                                                    }) {
                                                        HStack {
                                                            Text(horse.name)
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
                                        .frame(minHeight: 0)
                                    } else {
                                        // Выбранная лошадь или "Select"
                                        HStack {
                                            if let horse = selectedHorse {
                                                Text(horse.name)
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
                                
                                // Кнопка назад (стрелка) справа вверху
                                if showingHorsePicker {
                                    Button(action: {
                                        playButtonSound()
                                        showingHorsePicker = false
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
                                if !showingHorsePicker {
                                    showingHorsePicker = true
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Training Type Section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Training Type:")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                .padding(.bottom, 8)
                            
                            ZStack(alignment: .topTrailing) {
                                // Контейнер выбора типа тренировки
                                VStack(alignment: .leading, spacing: 0) {
                                    if showingTypePicker {
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
                                            
                                            // Список типов тренировок
                                            VStack(alignment: .leading, spacing: 12) {
                                                ForEach(TrainingType.allCases, id: \.self) { type in
                                                    Button(action: {
                                                        playButtonSound()
                                                        selectedType = type
                                                        showingTypePicker = false
                                                    }) {
                                                        HStack {
                                                            Text(type.displayName)
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
                                        .frame(minHeight: 0)
                                    } else {
                                        // Выбранный тип тренировки
                                        HStack {
                                            Text(selectedType.displayName)
                                                .font(.system(size: 14, weight: .regular))
                                                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
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
                                
                                // Кнопка назад (стрелка) справа вверху
                                if showingTypePicker {
                                    Button(action: {
                                        playButtonSound()
                                        showingTypePicker = false
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
                                if !showingTypePicker {
                                    showingTypePicker = true
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Duration Section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Duration:")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                .padding(.bottom, 8)
                            
                            HStack {
                                TextField("min", text: $duration)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                    .keyboardType(.numberPad)
                                    .placeholder(when: duration.isEmpty) {
                                        Text("min")
                                            .foregroundColor(Color(red: 0.627, green: 0.627, blue: 0.627)) // #A0A0A0
                                    }
                                
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
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Date Section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Date:")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                .padding(.bottom, 8)
                            
                            Button(action: {
                                playButtonSound()
                                showingDatePicker = true
                            }) {
                                HStack {
                                    Text(formatDate(date))
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
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Time:")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                .padding(.bottom, 8)
                            
                            Button(action: {
                                playButtonSound()
                                showingTimePicker = true
                            }) {
                                HStack {
                                    Text(formatTime(time))
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
                        
                        // Mood Section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Mood:")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                .padding(.bottom, 8)
                            
                            ZStack(alignment: .topTrailing) {
                                // Контейнер выбора настроения
                                VStack(alignment: .leading, spacing: 0) {
                                    if showingMoodPicker {
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
                                            
                                            // Список настроений
                                            VStack(alignment: .leading, spacing: 12) {
                                                ForEach(Array(Mood.allCases.enumerated()), id: \.element) { index, mood in
                                                    Button(action: {
                                                        playButtonSound()
                                                        selectedMood = mood
                                                        showingMoodPicker = false
                                                    }) {
                                                        HStack {
                                                            Text("\(mood.emoji) \(mood.rawValue)")
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
                                        .frame(minHeight: 0)
                                    } else {
                                        // Выбранное настроение или "Select"
                                        HStack {
                                            if let mood = selectedMood {
                                                Text("\(mood.emoji) \(mood.rawValue)")
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
                                
                                // Кнопка назад (стрелка) справа вверху
                                if showingMoodPicker {
                                    Button(action: {
                                        playButtonSound()
                                        showingMoodPicker = false
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
                                if !showingMoodPicker {
                                    showingMoodPicker = true
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Note Section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Note:")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                .padding(.bottom, 8)
                            
                            ZStack(alignment: .topLeading) {
                                if notes.isEmpty {
                                    Text("Note")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(Color(red: 0.627, green: 0.627, blue: 0.627)) // #A0A0A0
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                }
                                
                                TextEditor(text: $notes)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                    .keyboardType(.asciiCapable)
                                    .textInputAutocapitalization(.never)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 4)
                            }
                            .frame(width: 358, height: 65)
                            .background(Color(red: 0.922, green: 0.922, blue: 0.922)) // #EBEBEB
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 100) // Отступ для кнопки внизу
                    }
                }
            }
            .overlay(alignment: .bottom) {
                // Save Training Button
                Button(action: {
                    playButtonSound()
                    guard let horse = selectedHorse,
                          let durationInt = Int(duration) else { return }
                    
                    // Объединяем дату и время
                    let calendar = Calendar.current
                    let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                    let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
                    var combinedComponents = DateComponents()
                    combinedComponents.year = dateComponents.year
                    combinedComponents.month = dateComponents.month
                    combinedComponents.day = dateComponents.day
                    combinedComponents.hour = timeComponents.hour
                    combinedComponents.minute = timeComponents.minute
                    let combinedDate = calendar.date(from: combinedComponents) ?? date
                    
                    if let existingTraining = training {
                        // Обновляем существующую тренировку
                        var updatedTraining = existingTraining
                        updatedTraining.type = selectedType
                        updatedTraining.date = combinedDate
                        updatedTraining.duration = durationInt
                        updatedTraining.notes = notes
                        updatedTraining.mood = selectedMood ?? .calm
                        dataManager.updateTraining(updatedTraining)
                    } else {
                        // Создаем новую тренировку
                        let newTraining = Training(
                            horseId: horse.id,
                            date: combinedDate,
                            duration: durationInt,
                            type: selectedType,
                            notes: notes,
                            mood: selectedMood ?? .calm
                        )
                        dataManager.addTraining(newTraining)
                    }
                    dismiss()
                }) {
                    Text("Save Training")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 358, height: 50)
                        .background(canSave ? Color(red: 0.945, green: 0.0, blue: 0.173) : Color(red: 0.627, green: 0.627, blue: 0.627)) // #F1002C или #A0A0A0
                        .cornerRadius(50)
                }
                .disabled(!canSave)
                .padding(.horizontal, 16)
                .padding(.bottom, 99) // Отступ для панели навигации
            }
            .overlay(Group {
                if showingDatePicker {
                    DatePickerBottomSheet(selectedDate: $date, isPresented: $showingDatePicker)
                }
            })
            .overlay(Group {
                if showingTimePicker {
                    TimePickerBottomSheet(selectedDate: $time, isPresented: $showingTimePicker, onTimeSet: {
                        hasTimeSet = true
                    })
                }
            })
            .overlay(alignment: .bottom) {
                // Custom Tab Bar - скрывается при открытии пикеров
                if !showingDatePicker && !showingTimePicker && !showingHorsePicker && !showingTypePicker {
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
    
    private var canSave: Bool {
        selectedHorse != nil && !duration.isEmpty && Int(duration) != nil
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

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}
