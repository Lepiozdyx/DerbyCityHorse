//
//  TrainingsListView.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import SwiftUI

struct TrainingsListView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var dataManager = DataManager.shared
    @State private var showingAddTraining = false
    @State private var selectedHorse: Horse?
    @State private var selectedType: TrainingType?
    @State private var showingFilter = false
    @State private var swipedTrainingId: UUID?
    @State private var trainingToEdit: Training?
    
    var filteredTrainings: [Training] {
        var trainings = dataManager.getAllTrainings()
        
        if let horse = selectedHorse {
            trainings = trainings.filter { $0.horseId == horse.id }
        }
        
        if let type = selectedType {
            trainings = trainings.filter { $0.type == type }
        }
        
        return trainings
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header
                ZStack {
                    CustomHeaderView(title: "Trainings", showBackButton: false)
                    
                    // Кнопка фильтра справа
                    HStack {
                        Spacer()
                        Button(action: {
                            playButtonSound()
                            showingFilter.toggle()
                        }) {
                            Image("svg5")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        .padding(.trailing, 16)
                    }
                    .frame(height: 88)
                }
                
                if filteredTrainings.isEmpty {
                    VStack(spacing: 4) {
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("No Trainings Yet")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(red: 0.945, green: 0.0, blue: 0.173)) // #F1002C
                                .frame(width: 358)
                                .multilineTextAlignment(.center)
                            
                            Text("Start tracking your horse workouts to see them here.")
                                .font(.system(size: 20, weight: .regular))
                                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                .frame(width: 358)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 358, height: 81)
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filteredTrainings) { training in
                                TrainingListCard(
                                    training: training,
                                    swipedTrainingId: $swipedTrainingId,
                                    trainingToEdit: $trainingToEdit
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .overlay(alignment: .topTrailing) {
                // Выпадающее меню фильтров
                if showingFilter {
                    FilterDropdownView(
                        selectedHorse: $selectedHorse,
                        selectedType: $selectedType,
                        showingFilter: $showingFilter
                    )
                    .padding(.top, 90)
                    .padding(.trailing, 1)
                    .zIndex(1000)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button(action: {
                    playButtonSound()
                    if let firstHorse = dataManager.horses.first {
                        selectedHorse = firstHorse
                        showingAddTraining = true
                    }
                }) {
                    Text("Add Training")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 188, height: 50)
                        .background(dataManager.horses.isEmpty ? Color(red: 0.627, green: 0.627, blue: 0.627) : Color(red: 0.945, green: 0.0, blue: 0.173)) // Серый если нет лошадей, иначе красный #F1002C
                        .cornerRadius(50)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 100)
                .disabled(dataManager.horses.isEmpty)
            }
            .fullScreenCover(isPresented: $showingAddTraining) {
                if let horse = selectedHorse {
                    AddTrainingView(horse: horse)
                        .environmentObject(navigationManager)
                }
            }
            .fullScreenCover(item: $trainingToEdit) { training in
                if let horse = dataManager.horses.first(where: { $0.id == training.horseId }) {
                    AddTrainingView(horse: horse, training: training)
                        .environmentObject(navigationManager)
                }
            }
        }
    }
}

struct TrainingListCard: View {
    let training: Training
    @StateObject private var dataManager = DataManager.shared
    @Binding var swipedTrainingId: UUID?
    @Binding var trainingToEdit: Training?
    @State private var offset: CGFloat = 0
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }
    
    var horse: Horse? {
        dataManager.horses.first { $0.id == training.horseId }
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Кнопки редактирования и удаления (показываются при свайпе)
            // edit: left: 266px, delete: left: 324px от экрана
            // spacing между кнопками: 324 - 266 - 50 = 8px
            if offset < 0 {
                // Кнопка редактирования (желтая, круглая)
                Button(action: {
                    playButtonSound()
                    trainingToEdit = training
                    withAnimation {
                        offset = 0
                        swipedTrainingId = nil
                    }
                }) {
                    Image("edit")
                        .resizable()
                        .frame(width: 26, height: 26)
                        .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                }
                .frame(width: 50, height: 50)
                .background(Color(red: 1.0, green: 0.933, blue: 0.0)) // #FFEE00
                .clipShape(Circle())
                .offset(x: 258 + 8, y: 0) // Карточка 358px + отступ 8px
                
                // Кнопка удаления (красная, круглая)
                Button(action: {
                    playButtonSound()
                    withAnimation {
                        dataManager.deleteTraining(training)
                        swipedTrainingId = nil
                    }
                }) {
                    Image("delete")
                        .resizable()
                        .frame(width: 24, height: 30)
                        .foregroundColor(.white) // #FFFFFF
                }
                .frame(width: 50, height: 50)
                .background(Color(red: 0.945, green: 0.0, blue: 0.173)) // #F1002C
                .clipShape(Circle())
                .offset(x: 258 + 8 + 50 + 8, y: 0) // Карточка 358px + отступ 8px + edit кнопка 50px + spacing 8px
            }
            
            // Основной контент карточки
            ZStack(alignment: .topLeading) {
                // Левая сторона - все элементы с отступом 28px слева
                VStack(alignment: .leading, spacing: 0) {
                    // Имя лошади (top: 12px от верха карточки, height: 24px)
                    if let horse = horse {
                        Text(horse.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.945, green: 0.0, blue: 0.173)) // #F1002C
                            .frame(height: 24)
                            .padding(.top, 12)
                    }
                    
                    // Тип тренировки (top: 44px от верха карточки, height: 19px)
                    Text(training.type.displayName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                        .frame(height: 19)
                        .padding(.top, 8) // 44 - 12 - 24 = 8px между именем и типом
                    
                    // Дата (top: 71px от верха карточки, height: 17px)
                    Text(dateFormatter.string(from: training.date))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                        .frame(height: 17)
                        .padding(.top, 8) // 71 - 44 - 19 = 8px между типом и датой
                    
                    // Заметки (top: 96px от верха карточки, height: 17px)
                    Text(training.notes)
                        .font(.system(size: 14, weight: .regular))
                        .italic()
                        .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                        .frame(height: 17)
                        .padding(.top, 8) // 96 - 71 - 17 = 8px между датой и заметками
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 28)
                
                // Правая сторона - элементы выровнены по правому краю
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        // Длительность (top: 44px от верха карточки, height: 19px)
                        Text("\(training.duration) min")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                            .frame(height: 19)
                            .padding(.top, 44)
                            .padding(.trailing, 52) // left: 306px = right: 52px
                    }
                }
                
                // Настроение отдельно, правее длительности
                HStack {
                    Spacer()
                    HStack(spacing: 4) {
                        Text(training.mood.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                        Text(training.mood.emoji)
                            .font(.system(size: 14))
                    }
                    .frame(height: 17)
                    .padding(.top, 71) // top: 71px от верха карточки
                    .padding(.trailing, 33) // Уменьшаем отступ, чтобы было правее
                }
            }
            .frame(width: 358, height: 125)
            .background(Color(red: 0.92, green: 0.92, blue: 0.92)) // #EBEBEB
            .cornerRadius(8)
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newOffset = value.translation.width
                        if newOffset < 0 {
                            // Свайп влево - показываем кнопки
                            offset = max(newOffset, -100)
                            // Закрываем другие свайпы
                            if swipedTrainingId != training.id {
                                swipedTrainingId = training.id
                            }
                        } else if newOffset > 0 {
                            // Свайп вправо - закрываем свайп
                            offset = min(newOffset, 0)
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring()) {
                            if value.translation.width < -50 {
                                // Открываем свайп
                                offset = -100
                                swipedTrainingId = training.id
                            } else {
                                // Закрываем свайп
                                offset = 0
                                if swipedTrainingId == training.id {
                                    swipedTrainingId = nil
                                }
                            }
                        }
                    }
            )
            .onChange(of: swipedTrainingId) { newValue in
                if newValue != training.id && offset < 0 {
                    withAnimation(.spring()) {
                        offset = 0
                    }
                }
            }
        }
        .frame(height: 125)
    }
}

struct FilterDropdownView: View {
    @Binding var selectedHorse: Horse?
    @Binding var selectedType: TrainingType?
    @Binding var showingFilter: Bool
    @StateObject private var dataManager = DataManager.shared
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            // Секция лошадей
            VStack(alignment: .trailing, spacing: 0) {
                Button(action: {
                    playButtonSound()
                    selectedHorse = nil
                    showingFilter = false
                }) {
                    Text("All")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(selectedHorse == nil ? Color(red: 0.945, green: 0.0, blue: 0.173) : Color(red: 0.133, green: 0.133, blue: 0.133))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.vertical, 8)
                }
                
                ForEach(dataManager.horses) { horse in
                    Button(action: {
                        playButtonSound()
                        selectedHorse = horse
                        showingFilter = false
                    }) {
                        Text(horse.name)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.vertical, 8)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // Разделительная линия
            Rectangle()
                .fill(Color(red: 0.133, green: 0.133, blue: 0.133))
                .frame(height: 0.5)
            
            // Секция типов тренировок
            VStack(alignment: .trailing, spacing: 0) {
                ForEach(TrainingType.allCases, id: \.self) { type in
                    Button(action: {
                        playButtonSound()
                        if selectedType == type {
                            selectedType = nil
                        } else {
                            selectedType = type
                        }
                        showingFilter = false
                    }) {
                        Text(type.displayName)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.vertical, 8)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(width: 120)
        .background(Color.white)
        .cornerRadius(11, corners: [.bottomLeft])
        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 2)
    }
}
