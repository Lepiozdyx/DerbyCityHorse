//
//  CalendarView.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var dataManager = DataManager.shared
    @State private var currentDate = Date()
    @State private var selectedDate: Date?
    
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header
                CustomHeaderView(title: "Calendar", showBackButton: false)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Calendar Widget - 350x254px
                        VStack(spacing: 0) {
                            // Month Header
                            HStack {
                                Text(monthYearString)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(red: 0.945, green: 0.0, blue: 0.173)) // #F1002C
                                
                                Spacer()
                                
                                // Navigation Arrows
                                HStack(spacing: 28) {
                                    Button(action: {
                                        playButtonSound()
                                        previousMonth()
                                    }) {
                                        ArrowShape()
                                            .stroke(Color(red: 0.133, green: 0.133, blue: 0.133), lineWidth: 2) // #222222
                                            .frame(width: 9, height: 18)
                                    }
                                    
                                    Button(action: {
                                        playButtonSound()
                                        nextMonth()
                                    }) {
                                        ArrowShape()
                                            .stroke(Color(red: 0.133, green: 0.133, blue: 0.133), lineWidth: 2) // #222222
                                            .frame(width: 9, height: 18)
                                            .scaleEffect(x: -1, y: 1) // Зеркальное отражение по горизонтали
                                    }
                                }
                                .frame(width: 46, height: 18)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 15)
                            .padding(.bottom, 8)
                            
                            // Weekday Headers
                            HStack(spacing: 0) {
                                ForEach(Array(["m", "t", "w", "t", "f", "s", "s"].enumerated()), id: \.offset) { index, day in
                                    Text(day)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 4)
                            
                            // Divider Line
                            Rectangle()
                                .fill(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                .frame(height: 0.3)
                                .padding(.horizontal, 16)
                            
                            // Calendar Days Grid
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                                ForEach(Array(calendarDays.enumerated()), id: \.offset) { index, date in
                                    if let date = date {
                                        CalendarDayView(
                                            date: date,
                                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate ?? Date()),
                                            eventTypes: dataManager.getCalendarEvents(for: date),
                                            isCurrentMonth: calendar.isDate(date, equalTo: currentDate, toGranularity: .month)
                                        ) {
                                            selectedDate = date
                                        }
                                    } else {
                                        Color.clear
                                            .frame(height: 22)
                                    }
                                }
                            }
                            .padding(.horizontal, 15)
                            .padding(.top, 6)
                            .padding(.bottom, 16)
                        }
                        .frame(width: 350, height: 254)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(red: 0.945, green: 0.0, blue: 0.173), lineWidth: 1) // #F1002C
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                        
                        // Gradient Line
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
                            .padding(.top, 18)
                        
                        // Empty State or Events
                        if let selectedDate = selectedDate {
                            let events = dataManager.getEvents(for: selectedDate)
                            
                            if events.isEmpty {
                                VStack(spacing: 4) {
                                    Text("No Activity Scheduled")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(Color(red: 0.945, green: 0.0, blue: 0.173)) // #F1002C
                                        .frame(width: 358)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("There are no care actions or trainings recorded for this day.")
                                        .font(.system(size: 20, weight: .regular))
                                        .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                        .frame(width: 358)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(width: 358, height: 81)
                                .padding(.top, 18)
                            } else {
                                VStack(alignment: .leading, spacing: 0) {
                                    // Заголовок даты
                                    Text(formatDateFull(selectedDate))
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                        .frame(width: 358, alignment: .leading)
                                        .padding(.leading, 16)
                                        .padding(.top, 18)
                                    
                                    // Список событий
                                    VStack(spacing: 29) {
                                        ForEach(events, id: \.id) { event in
                                            EventRow(event: event)
                                        }
                                    }
                                    .padding(.leading, 16)
                                    .padding(.top, 12)
                                }
                                .frame(width: 358)
                                .padding(.top, 0)
                            }
                        } else {
                            VStack(spacing: 4) {
                                Text("No Activity Scheduled")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(red: 0.945, green: 0.0, blue: 0.173)) // #F1002C
                                    .frame(width: 358)
                                    .multilineTextAlignment(.center)
                                
                                Text("There are no care actions or trainings recorded for this day.")
                                    .font(.system(size: 20, weight: .regular))
                                    .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                    .frame(width: 358)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: 358, height: 81)
                            .padding(.top, 18)
                        }
                        
                        Spacer()
                            .frame(height: 100)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .overlay(alignment: .bottom) {
                // Custom Tab Bar
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
                            }
                            
                            TabBarButton(
                                inactiveImage: "m-2-1",
                                activeImage: "m-2-2",
                                title: "Calendar",
                                isSelected: navigationManager.selectedTab == 1
                            ) {
                                navigationManager.navigateToCalendar()
                            }
                            
                            TabBarButton(
                                inactiveImage: "m-3-1",
                                activeImage: "m-3-2",
                                title: "Trainings",
                                isSelected: navigationManager.selectedTab == 2
                            ) {
                                navigationManager.navigateToTrainings()
                            }
                            
                            TabBarButton(
                                inactiveImage: "m-4-1",
                                activeImage: "m-4-2",
                                title: "Reminders",
                                isSelected: navigationManager.selectedTab == 3
                            ) {
                                navigationManager.navigateToReminders()
                            }
                        }
                        .frame(height: 83)
                        .background(Color(red: 0.92, green: 0.92, blue: 0.92)) // #EBEBEB
                    }
                }
            }
            .onAppear {
                if selectedDate == nil {
                    selectedDate = Date()
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: currentDate)
    }
    
    private var calendarDays: [Date?] {
        guard let firstDayOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.start else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let daysToSubtract = (firstWeekday + 5) % 7 // Adjust for Monday start
        
        var days: [Date?] = []
        
        // Add empty cells for days before month start
        for _ in 0..<daysToSubtract {
            days.append(nil)
        }
        
        // Add days of the month
        var currentDay = firstDayOfMonth
        while calendar.isDate(currentDay, equalTo: currentDate, toGranularity: .month) {
            days.append(currentDay)
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDay) {
                currentDay = nextDay
            } else {
                break
            }
        }
        
        // Fill remaining cells to complete grid
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    
    private func formatDateFull(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date).uppercased()
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let eventTypes: [CalendarEventType]
    let isCurrentMonth: Bool
    let action: () -> Void
    
    private let calendar = Calendar.current
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    var body: some View {
        Button(action: {
            playButtonSound()
            action()
        }) {
            VStack(spacing: 2) {
                // Event indicator circles (above date)
                if !eventTypes.isEmpty && isCurrentMonth {
                    HStack(spacing: 3) {
                        ForEach(eventTypes.prefix(3), id: \.self) { eventType in
                            Circle()
                                .fill(eventTypeColor(eventType))
                                .frame(width: 6, height: 6)
                        }
                    }
                    .frame(height: 6)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 6, height: 6)
                }
                
                // Date number
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(height: 22)
                    .foregroundColor(
                        isCurrentMonth ?
                        (isToday ? Color(red: 0.945, green: 0.0, blue: 0.173) : // Красный если сегодня
                         (isSelected ? Color(red: 0.0, green: 0.467, blue: 1.0) : Color(red: 0.133, green: 0.133, blue: 0.133))) : // Синий если выбрано, иначе черный
                        Color(red: 0.525, green: 0.525, blue: 0.525) // #868686 для дат из другого месяца
                    )
                    .underline((isSelected || isToday) && isCurrentMonth)
            }
            .frame(height: 22)
        }
    }
    
    private func eventTypeColor(_ type: CalendarEventType) -> Color {
        switch type {
        case .training:
            return Color(red: 0.0, green: 0.467, blue: 1.0) // #0077FF - синий
        case .important:
            return Color(red: 0.945, green: 0.0, blue: 0.173) // #F1002C - красный
        case .regular:
            return Color(red: 1.0, green: 0.933, blue: 0.0) // #FFEE00 - желтый
        case .other:
            return Color(red: 0.0, green: 0.8, blue: 0.4) // Зеленый для других событий
        }
    }
}

struct EventRow: View {
    let event: CalendarEvent
    
    private var timeString: String? {
        switch event {
        case .journal(let entry):
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: entry.date)
        case .training:
            return nil
        }
    }
    
    var body: some View {
        HStack {
            switch event {
            case .journal(let entry):
                Text("\(entry.actionType.emoji) \(entry.actionType.displayName)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.945, green: 0.0, blue: 0.173)) // #F1002C
                
                Spacer()
                
                if let timeString = timeString {
                    Text(timeString)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                        .frame(width: 49, alignment: .trailing)
                }
            case .training(let training):
                Text(training.type.displayName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.945, green: 0.0, blue: 0.173)) // #F1002C
                
                Spacer()
                
                Text("\(training.duration) min")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                    .frame(width: 49, alignment: .trailing)
            }
        }
        .frame(width: 358, height: 17)
    }
}

extension CalendarEvent: Identifiable {
    var id: UUID {
        switch self {
        case .journal(let entry):
            return entry.id
        case .training(let training):
            return training.id
        }
    }
}

struct ArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Стрелка влево: линия от правого верхнего угла к левому центру, затем к правому нижнему углу
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return path
    }
}
