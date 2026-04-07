//
//  HorsesListView.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import SwiftUI

struct HorsesListView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var dataManager = DataManager.shared
    @State private var showingAddHorse = false
    @State private var selectedHorse: Horse?
    @State private var horseToEdit: Horse?
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header (без кнопки назад)
                CustomHeaderView(title: "My Horses", showBackButton: false)
                
                if dataManager.horses.isEmpty {
                    GeometryReader { geometry in
                        ZStack(alignment: .bottom) {
                            VStack(spacing: 4) {
                                Spacer()
                                    .frame(height: 100)
                                
                                VStack(spacing: 4) {
                                    Text("No horses yet")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(Color(red: 0.945, green: 0.0, blue: 0.173)) // #F1002C
                                        .frame(width: 358)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("Add your first horse to start tracking care and training")
                                        .font(.system(size: 20, weight: .regular))
                                        .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                        .frame(width: 358)
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(0)
                                }
                                .frame(width: 358, height: 81)
                                
                                Spacer()
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            
                            // Кнопка внизу экрана, выше нижней панели навигации
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
                            .padding(.bottom) // 83px для нижней панели + 16px отступ
                        }
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(dataManager.horses) { horse in
                                HorseCardView(horse: horse) {
                                    selectedHorse = horse
                                } onEdit: {
                                    // Устанавливаем лошадь для редактирования - экран откроется автоматически
                                    horseToEdit = horse
                                } onDelete: {
                                    dataManager.deleteHorse(horse)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        

                    }
                }
            }
            .fullScreenCover(isPresented: $showingAddHorse) {
                AddEditHorseView(horse: nil)
                    .environmentObject(navigationManager)
            }
            .fullScreenCover(item: $selectedHorse) { horse in
                HorseDetailView(horse: horse)
                    .environmentObject(navigationManager)
            }
            .fullScreenCover(item: $horseToEdit) { horse in
                AddEditHorseView(horse: horse)
                    .environmentObject(navigationManager)
            }
        }
    }
}

struct HorseCardView: View {
    let horse: Horse
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showingEditDelete = false
    
    var body: some View {
        ZStack {
            // Основная карточка
            VStack(alignment: .leading, spacing: 0) {
                // Photo Section - 151x151 with rounded bottom corners only
                ZStack(alignment: .topTrailing) {
                    if let photo = horse.photo {
                        photo
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 151, height: 151)
                            .clipShape(
                                .rect(
                                    topLeadingRadius: 0,
                                    bottomLeadingRadius: 20,
                                    bottomTrailingRadius: 20,
                                    topTrailingRadius: 0
                                )
                            )
                    } else {
                        Rectangle()
                            .fill(Color(red: 0.92, green: 0.92, blue: 0.92)) // #EBEBEB
                            .frame(width: 151, height: 151)
                            .clipShape(
                                .rect(
                                    topLeadingRadius: 0,
                                    bottomLeadingRadius: 20,
                                    bottomTrailingRadius: 20,
                                    topTrailingRadius: 0
                                )
                            )
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            )
                    }
                    
                    // Red border around photo
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color(red: 0.945, green: 0.0, blue: 0.173), lineWidth: 1)
                        .frame(width: 151, height: 151)
                        .clipShape(
                            .rect(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: 20,
                                bottomTrailingRadius: 20,
                                topTrailingRadius: 0
                            )
                        )
                }
                
                // Text Section
                VStack(alignment: .leading, spacing: 3) {
                    Text(horse.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.945, green: 0.0, blue: 0.173)) // #F1002C
                    
                    Text(horse.breed)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                }
                .padding(.leading, 8)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
            .frame(width: 151, height: 202)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(red: 0.945, green: 0.0, blue: 0.173), lineWidth: 1) // #F1002C
            )
            
            // Затемненный фон и кнопки при долгом нажатии
            if showingEditDelete {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.5))
                    .frame(width: 151, height: 202)
                
                // Кнопки Edit и Delete
                VStack(spacing: 12) {
                    // Кнопка Edit
                    Button(action: {
                        playButtonSound()
                        onEdit()
                        showingEditDelete = false
                    }) {
                        Text("Edit")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 124, height: 28)
                            .background(Color(red: 0.945, green: 0.0, blue: 0.173)) // #F1002C
                            .cornerRadius(50)
                    }
                    
                    // Кнопка Delete
                    Button(action: {
                        playButtonSound()
                        onDelete()
                        showingEditDelete = false
                    }) {
                        Text("Delete")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(red: 0.945, green: 0.0, blue: 0.173)) // #F1002C
                            .frame(width: 124, height: 28)
                            .background(Color.white)
                            .cornerRadius(50)
                    }
                }
            }
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            withAnimation {
                showingEditDelete = true
            }
        }
        .onTapGesture {
            playButtonSound()
            if showingEditDelete {
                withAnimation {
                    showingEditDelete = false
                }
            } else {
                onTap()
            }
        }
    }
}

#Preview {
    HorsesListView()
}
