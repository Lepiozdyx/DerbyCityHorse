//
//  TimePickerBottomSheet.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import SwiftUI

struct TimePickerBottomSheet: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    var onTimeSet: (() -> Void)?
    
    @State private var selectedHour: Int
    @State private var selectedMinute: Int
    @State private var hourScrollTimer: Timer?
    @State private var minuteScrollTimer: Timer?
    
    private let calendar = Calendar.current
    
    init(selectedDate: Binding<Date>, isPresented: Binding<Bool>, onTimeSet: (() -> Void)? = nil) {
        self._selectedDate = selectedDate
        self._isPresented = isPresented
        self.onTimeSet = onTimeSet
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: selectedDate.wrappedValue)
        self._selectedHour = State(initialValue: components.hour ?? 0)
        self._selectedMinute = State(initialValue: components.minute ?? 0)
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
                        Text("Pick a time")
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
                            // Hour Column
                            hourPickerColumn
                            
                            // Minute Column
                            minutePickerColumn
                        }
                        .frame(height: 220)
                    }
                    
                    // Save Button
                    VStack(spacing: 0) {
                        Button(action: {
                            playButtonSound()
                            // Обновляем время перед закрытием
                            updateTime()
                            onTimeSet?()
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
            let components = calendar.dateComponents([.hour, .minute], from: selectedDate)
            selectedHour = components.hour ?? 0
            selectedMinute = components.minute ?? 0
        }
        .onDisappear {
            hourScrollTimer?.invalidate()
            minuteScrollTimer?.invalidate()
        }
    }
    
    private func updateTime() {
        var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        components.hour = selectedHour
        components.minute = selectedMinute
        if let newDate = calendar.date(from: components) {
            selectedDate = newDate
        }
    }
    
    private var hourPickerColumn: some View {
        ScrollViewReader { proxy in
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(0..<24, id: \.self) { hour in
                            MonthDayRow(
                                text: String(format: "%02d", hour),
                                isSelected: hour == selectedHour,
                                isActive: hour == selectedHour
                            )
                            .id(hour)
                            .background(
                                GeometryReader { rowGeo in
                                    Color.clear.preference(
                                        key: RowPositionKey.self,
                                        value: [RowPosition(id: hour, y: rowGeo.frame(in: .named("hourSpace")).midY)]
                                    )
                                }
                            )
                        }
                    }
                    .padding(.vertical, 88)
                }
                .coordinateSpace(name: "hourSpace")
                .scrollIndicators(.hidden)
                .scrollTargetLayout()
                .onPreferenceChange(RowPositionKey.self) { positions in
                    guard geometry.size.height > 0 else { return }
                    let center = geometry.size.height / 2
                    var closest = selectedHour
                    var minDist: CGFloat = .infinity
                    
                    for pos in positions {
                        let dist = abs(pos.y - center)
                        if dist < minDist && dist.isFinite {
                            minDist = dist
                            closest = pos.id
                        }
                    }
                    
                    if closest != selectedHour && minDist < 22 && minDist.isFinite {
                        selectedHour = closest
                        updateTime()
                    }
                    
                    // Автоматическое выравнивание через секунду после окончания скролла
                    hourScrollTimer?.invalidate()
                    hourScrollTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(selectedHour, anchor: .center)
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo(selectedHour, anchor: .center)
                    }
                }
            }
            .frame(width: 179)
        }
    }
    
    private var minutePickerColumn: some View {
        ScrollViewReader { proxy in
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(0..<60, id: \.self) { minute in
                            MonthDayRow(
                                text: String(format: "%02d", minute),
                                isSelected: minute == selectedMinute,
                                isActive: minute == selectedMinute
                            )
                            .id(minute)
                            .background(
                                GeometryReader { rowGeo in
                                    Color.clear.preference(
                                        key: RowPositionKey.self,
                                        value: [RowPosition(id: minute, y: rowGeo.frame(in: .named("minuteSpace")).midY)]
                                    )
                                }
                            )
                        }
                    }
                    .padding(.vertical, 88)
                }
                .coordinateSpace(name: "minuteSpace")
                .scrollIndicators(.hidden)
                .scrollTargetLayout()
                .onPreferenceChange(RowPositionKey.self) { positions in
                    guard geometry.size.height > 0 else { return }
                    let center = geometry.size.height / 2
                    var closest = selectedMinute
                    var minDist: CGFloat = .infinity
                    
                    for pos in positions {
                        let dist = abs(pos.y - center)
                        if dist < minDist && dist.isFinite {
                            minDist = dist
                            closest = pos.id
                        }
                    }
                    
                    if closest != selectedMinute && minDist < 22 && minDist.isFinite {
                        selectedMinute = closest
                        updateTime()
                    }
                    
                    // Автоматическое выравнивание через секунду после окончания скролла
                    minuteScrollTimer?.invalidate()
                    minuteScrollTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(selectedMinute, anchor: .center)
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo(selectedMinute, anchor: .center)
                    }
                }
            }
            .frame(width: 179)
        }
    }
}
