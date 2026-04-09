//
//  DatePickerBottomSheet.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import SwiftUI

struct DatePickerBottomSheet: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    @State private var selectedMonth: Int
    @State private var selectedDay: Int
    @State private var selectedYear: Int
    @State private var monthScrollTimer: Timer?
    @State private var dayScrollTimer: Timer?
    
    private let calendar = Calendar.current
    private let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    init(selectedDate: Binding<Date>, isPresented: Binding<Bool>) {
        self._selectedDate = selectedDate
        self._isPresented = isPresented
        
        let components = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate.wrappedValue)
        self._selectedMonth = State(initialValue: components.month ?? 1)
        self._selectedDay = State(initialValue: components.day ?? 1)
        self._selectedYear = State(initialValue: components.year ?? 2026)
    }
    
    var body: some View {
        ZStack {
            // Затемненный фон
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    playButtonSound()
                    isPresented = false
                }
            
            // Bottom Sheet
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 8) {
                    // Title
                    HStack {
                        Spacer()
                        Text("Pick a date")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .frame(height: 44)
                    .overlay(
                        Rectangle()
                            .fill(Color(red: 0.729, green: 0.729, blue: 0.729)) // #BABABA
                            .frame(height: 1),
                        alignment: .bottom
                    )
                    .padding(.horizontal, 10)
                    
                    // Picker Content
                    ZStack {
                        // Фон
                        Color(red: 0.909, green: 0.909, blue: 0.909) // #E8E8E8
                            .frame(height: 220)
                        
                        HStack(spacing: 0) {
                            // Month Column
                            monthPickerColumn
                            
                            // Day Column
                            dayPickerColumn
                        }
                        .frame(height: 220)
                    }
                    
                    // Save Button
                    VStack(spacing: 0) {
                        Button(action: {
                            playButtonSound()
                            // Сохраняем время из исходной даты
                            let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: selectedDate)
                            var components = DateComponents()
                            components.year = selectedYear
                            components.month = selectedMonth
                            components.day = selectedDay
                            // Сохраняем время из исходной даты, если оно есть, иначе используем текущее время
                            if let hour = timeComponents.hour, let minute = timeComponents.minute {
                                components.hour = hour
                                components.minute = minute
                                components.second = timeComponents.second ?? 0
                            } else {
                                // Если времени нет, используем текущее время
                                let now = Date()
                                components.hour = calendar.component(.hour, from: now)
                                components.minute = calendar.component(.minute, from: now)
                                components.second = 0
                            }
                            if let newDate = calendar.date(from: components) {
                                selectedDate = newDate
                            }
                            isPresented = false
                        }) {
                            Text("Save")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 358, height: 50)
                                .background(Color(red: 0.945, green: 0.0, blue: 0.173)) // #F1002C
                                .cornerRadius(50)
                        }
                        .padding(.bottom, 16)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 0)
                .background(Color(red: 0.909, green: 0.909, blue: 0.909)) // #E8E8E8
                .cornerRadius(8, corners: [.topLeft, .topRight])
            }
        }
        .onAppear {
            let components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
            selectedMonth = components.month ?? 1
            selectedDay = components.day ?? 1
            selectedYear = components.year ?? 2026
        }
        .onDisappear {
            monthScrollTimer?.invalidate()
            dayScrollTimer?.invalidate()
        }
    }
    
    private var daysInMonth: Int {
        let dateComponents = DateComponents(year: selectedYear, month: selectedMonth)
        if let date = calendar.date(from: dateComponents),
           let range = calendar.range(of: .day, in: .month, for: date) {
            return range.count
        }
        return 31
    }
    
    private func updateDate() {
        // Сохраняем время из исходной даты
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: selectedDate)
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = selectedDay
        // Сохраняем время из исходной даты
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.second = timeComponents.second
        if let newDate = calendar.date(from: components) {
            selectedDate = newDate
        }
    }
    
    private var monthPickerColumn: some View {
        ScrollViewReader { proxy in
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(0..<months.count, id: \.self) { monthIndex in
                            MonthDayRow(
                                text: months[monthIndex],
                                isSelected: monthIndex + 1 == selectedMonth,
                                isActive: monthIndex + 1 == selectedMonth
                            )
                            .id(monthIndex)
                            .background(
                                GeometryReader { rowGeo in
                                    Color.clear.preference(
                                        key: RowPositionKey.self,
                                        value: [RowPosition(id: monthIndex, y: rowGeo.frame(in: .named("monthSpace")).midY)]
                                    )
                                }
                            )
                        }
                    }
                    .padding(.vertical, 88)
                }
                .coordinateSpace(name: "monthSpace")
                .scrollIndicators(.hidden)
                .compatScrollTargetLayout()
                .onPreferenceChange(RowPositionKey.self) { positions in
                    guard geometry.size.height > 0 else { return }
                    let center = geometry.size.height / 2
                    var closest = selectedMonth - 1
                    var minDist: CGFloat = .infinity
                    
                    for pos in positions {
                        let dist = abs(pos.y - center)
                        if dist < minDist && dist.isFinite {
                            minDist = dist
                            closest = pos.id
                        }
                    }
                    
                    if closest + 1 != selectedMonth && minDist < 22 && minDist.isFinite {
                        selectedMonth = closest + 1
                        updateDate()
                    }
                    
                    // Автоматическое выравнивание через секунду после окончания скролла
                    monthScrollTimer?.invalidate()
                    monthScrollTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(selectedMonth - 1, anchor: .center)
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo(selectedMonth - 1, anchor: .center)
                    }
                }
            }
            .frame(width: 225.41)
        }
    }
    
    private var dayPickerColumn: some View {
        ScrollViewReader { proxy in
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(1...daysInMonth, id: \.self) { day in
                            MonthDayRow(
                                text: "\(day)",
                                isSelected: day == selectedDay,
                                isActive: day == selectedDay
                            )
                            .id(day)
                            .background(
                                GeometryReader { rowGeo in
                                    Color.clear.preference(
                                        key: RowPositionKey.self,
                                        value: [RowPosition(id: day, y: rowGeo.frame(in: .named("daySpace")).midY)]
                                    )
                                }
                            )
                        }
                    }
                    .padding(.vertical, 88)
                }
                .coordinateSpace(name: "daySpace")
                .scrollIndicators(.hidden)
                .compatScrollTargetLayout()
                .onPreferenceChange(RowPositionKey.self) { positions in
                    guard geometry.size.height > 0 else { return }
                    let center = geometry.size.height / 2
                    var closest = selectedDay
                    var minDist: CGFloat = .infinity
                    
                    for pos in positions {
                        let dist = abs(pos.y - center)
                        if dist < minDist && dist.isFinite {
                            minDist = dist
                            closest = pos.id
                        }
                    }
                    
                    if closest != selectedDay && minDist < 22 && minDist.isFinite {
                        selectedDay = closest
                        updateDate()
                    }
                    
                    // Автоматическое выравнивание через секунду после окончания скролла
                    dayScrollTimer?.invalidate()
                    dayScrollTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(selectedDay, anchor: .center)
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo(selectedDay, anchor: .center)
                    }
                }
            }
            .frame(width: 114.91)
        }
    }
}

struct RowPosition: Equatable {
    let id: Int
    let y: CGFloat
}

struct RowPositionKey: PreferenceKey {
    static var defaultValue: [RowPosition] = []
    
    static func reduce(value: inout [RowPosition], nextValue: () -> [RowPosition]) {
        value.append(contentsOf: nextValue())
    }
}

struct MonthDayRow: View {
    let text: String
    let isSelected: Bool
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                if isActive {
                    Text(text)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                } else {
                    Text(text)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.clear)
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.549, green: 0.549, blue: 0.549), // #8C8C8C
                                    Color.white
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .mask(Text(text)
                                .font(.system(size: 17, weight: .regular)))
                        )
                }
                Spacer()
            }
            .frame(height: 44)
            
            if isActive {
                Rectangle()
                    .fill(Color(red: 0.729, green: 0.729, blue: 0.729)) // #BABABA
                    .frame(height: 1)
            }
        }
        .opacity(isSelected ? 1.0 : 0.5)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    @ViewBuilder
    func compatScrollTargetLayout() -> some View {
        if #available(iOS 17.0, *) {
            self.scrollTargetLayout()
        } else {
            self
        }
    }
}
