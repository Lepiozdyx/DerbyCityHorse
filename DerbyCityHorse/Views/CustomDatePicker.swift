//
//  CustomDatePicker.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import SwiftUI

struct CustomDatePicker: View {
    @Binding var selectedDate: Date
    @State private var currentMonth: Date
    @StateObject private var dataManager = DataManager.shared
    
    let onDateSelected: (Date) -> Void
    
    private let calendar = Calendar.current
    private let weekdays = ["m", "t", "w", "t", "f", "s", "s"]
    
    init(selectedDate: Binding<Date>, onDateSelected: @escaping (Date) -> Void) {
        self._selectedDate = selectedDate
        self._currentMonth = State(initialValue: selectedDate.wrappedValue)
        self.onDateSelected = onDateSelected
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Month Header
            HStack {
                Text(monthYearString)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 0.945, green: 0.0, blue: 0.173)) // #F1002C
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Spacer()
                
                // Arrows
                HStack(spacing: 8) {
                    Button(action: {
                        playButtonSound()
                        previousMonth()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 16, height: 16)
                    }
                    
                    Button(action: {
                        playButtonSound()
                        nextMonth()
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            // Weekday Headers
            HStack(spacing: 0) {
                ForEach(Array(weekdays.enumerated()), id: \.offset) { index, day in
                    Text(day)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            
            // Divider
            Rectangle()
                .fill(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                .frame(height: 0.3)
                .padding(.horizontal, 12)
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                ForEach(Array(calendarDays.enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        CalendarDayButton(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            eventTypes: dataManager.getCalendarEvents(for: date),
                            isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                        ) {
                            selectedDate = date
                            onDateSelected(date)
                        }
                    } else {
                        Color.clear
                            .frame(height: 28)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(width: 320, height: 240)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(red: 0.945, green: 0.0, blue: 0.173), lineWidth: 1) // #F1002C
        )
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: currentMonth).capitalized
    }
    
    private var calendarDays: [Date?] {
        guard let firstDayOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start else {
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
        while calendar.isDate(currentDay, equalTo: currentMonth, toGranularity: .month) {
            days.append(currentDay)
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDay) {
                currentDay = nextDay
            } else {
                break
            }
        }
        
        // Add days from next month to complete grid
        while days.count % 7 != 0 {
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDay) {
                days.append(nextDay)
                currentDay = nextDay
            } else {
                days.append(nil)
            }
        }
        
        return days
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newDate
        }
    }
}

struct CalendarDayButton: View {
    let date: Date
    let isSelected: Bool
    let eventTypes: [CalendarEventType]
    let isCurrentMonth: Bool
    let action: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: {
            playButtonSound()
            action()
        }) {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(
                        isCurrentMonth ?
                        (isSelected ? Color(red: 0.945, green: 0.0, blue: 0.173) : Color(red: 0.133, green: 0.133, blue: 0.133)) :
                        Color(red: 0.525, green: 0.525, blue: 0.525) // #868686
                    )
                    .underline(isSelected && isCurrentMonth)
                
                if !eventTypes.isEmpty && isCurrentMonth {
                    HStack(spacing: 2) {
                        ForEach(eventTypes.prefix(3), id: \.self) { eventType in
                            Circle()
                                .fill(eventTypeColor(eventType))
                                .frame(width: 5, height: 5)
                        }
                    }
                    .frame(height: 5)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 5, height: 5)
                }
            }
            .frame(height: 28)
        }
    }
    
    private func eventTypeColor(_ type: CalendarEventType) -> Color {
        switch type {
        case .training:
            return Color(red: 0.0, green: 0.467, blue: 1.0) // #0077FF
        case .important:
            return Color(red: 0.945, green: 0.0, blue: 0.173) // #F1002C
        case .regular:
            return Color(red: 1.0, green: 0.933, blue: 0.0) // #FFEE00
        case .other:
            return Color(red: 0.0, green: 0.8, blue: 0.4) // Зеленый для других событий
        }
    }
}
