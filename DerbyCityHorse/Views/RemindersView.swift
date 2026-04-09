//
//  RemindersView.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import SwiftUI

struct RemindersView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @State private var swipedReminderId: UUID?
    
    var activeReminders: [Reminder] {
        let reminders = dataManager.getActiveReminders()
        // Отладочная информация
        print("Total reminders: \(dataManager.reminders.count)")
        print("Active reminders: \(reminders.count)")
        return reminders
    }
    
    var hasRedReminder: Bool {
        activeReminders.contains { reminder in
            Calendar.current.isDateInToday(reminder.date)
        }
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header
                CustomHeaderView(title: "Reminders", showBackButton: false)
                
                if activeReminders.isEmpty {
                    VStack(spacing: 4) {
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("No Active Reminders")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(red: 0.945, green: 0.0, blue: 0.173)) // #F1002C
                                .frame(width: 358)
                                .multilineTextAlignment(.center)
                            
                            Text("Add reminders to stay on track with your horse care.")
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
                        VStack(spacing: 0) {
                            // Градиентная линия вверху (только если есть красное напоминание)
                            if hasRedReminder {
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
                                    .padding(.top, 16)
                            }
                            
                            VStack(spacing: 0) {
                                ForEach(activeReminders) { reminder in
                                    ReminderRow(
                                        reminder: reminder,
                                        swipedReminderId: $swipedReminderId
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, hasRedReminder ? 12 : 16)
                            .padding(.bottom, 20)
                        }
                    }
                    .simultaneousGesture(
                        TapGesture()
                            .onEnded {
                                // Закрываем свайп при тапе на ScrollView
                                withAnimation {
                                    swipedReminderId = nil
                                }
                            }
                    )
                }
            }
        }
    }
}

struct ReminderRow: View {
    let reminder: Reminder
    @ObservedObject private var dataManager = DataManager.shared
    @Binding var swipedReminderId: UUID?
    @State private var offset: CGFloat = 0
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(reminder.date)
    }
    
    private var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(reminder.date)
    }
    
    var dateString: String {
        if isToday {
            return "Today"
        } else if isTomorrow {
            return "Tomorrow"
        } else {
            return dateFormatter.string(from: reminder.date)
        }
    }
    
    var backgroundColor: Color {
        isToday ? Color(red: 0.945, green: 0.0, blue: 0.173) : Color(red: 1.0, green: 0.933, blue: 0.0) // #F1002C или #FFEE00
    }
    
    var textColor: Color {
        isToday ? .white : Color(red: 0.133, green: 0.133, blue: 0.133) // #222222
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Кнопка удаления (показывается только при свайпе, без фона)
            if offset < 0 {
                HStack {
                    Spacer()
                    Button(action: {
                        playButtonSound()
                        withAnimation {
                            dataManager.deleteReminder(reminder)
                            swipedReminderId = nil
                        }
                    }) {
                        Image("delete")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(red: 0.945, green: 0.0, blue: 0.173))
                            .frame(width: 50, height: 48)
                    }
                }
            }
            
            // Основной контент
            HStack(spacing: 0) {
                // Emoji + текст
                HStack(spacing: 0) {
                    Text(reminder.actionType.emoji)
                        .font(.system(size: 20))
                    
                    Text(" \(reminder.actionType.displayName)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(textColor)
                }
                .padding(.leading, 28)
                
                Spacer()
                
                // Дата справа
                Text(dateString)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(textColor)
                    .padding(.trailing, 28)
            }
            .frame(width: 358, height: 48)
            .background(backgroundColor)
            .cornerRadius(8)
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newOffset = value.translation.width
                        if newOffset < 0 {
                            // Свайп влево - показываем кнопку удаления
                            offset = max(newOffset, -50)
                            // Закрываем другие свайпы
                            if swipedReminderId != reminder.id {
                                swipedReminderId = reminder.id
                            }
                        } else if newOffset > 0 {
                            // Свайп вправо - закрываем свайп
                            offset = min(newOffset, 0)
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring()) {
                            if value.translation.width < -25 {
                                // Открываем свайп
                                offset = -50
                                swipedReminderId = reminder.id
                            } else {
                                // Закрываем свайп
                                offset = 0
                                if swipedReminderId == reminder.id {
                                    swipedReminderId = nil
                                }
                            }
                        }
                    }
            )
            .onChange(of: swipedReminderId) { newValue in
                if newValue != reminder.id && offset < 0 {
                    withAnimation(.spring()) {
                        offset = 0
                    }
                }
            }
        }
        .frame(height: 48)
        .padding(.bottom, 12)
    }
}
