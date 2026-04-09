//
//  AddTrainingView.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import SwiftUI

struct AddTrainingView: View {
    private enum Field: Hashable {
        case notes
    }

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var navigationManager: NavigationManager
    @ObservedObject private var dataManager = DataManager.shared
    
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
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var focusedField: Field?
    
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
        AnyView(
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
                    AnyView(
                    VStack(alignment: .leading, spacing: 0) {
                        horseSection
                        
                        trainingTypeSection
                        
                        // Duration Section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Duration:")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                .padding(.bottom, 8)
                            
                            HStack {
                                DoneNumberField(text: $duration, placeholder: "min")
                                    .frame(height: 22)
                                
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
                        
                        moodSection
                        
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
                                    .focused($focusedField, equals: .notes)
                                    .onChange(of: notes) { newValue in
                                        if newValue.contains("\n") {
                                            notes = newValue.replacingOccurrences(of: "\n", with: " ")
                                            focusedField = nil
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 4)
                            }
                            .frame(width: 358, height: 65)
                            .background(Color(red: 0.922, green: 0.922, blue: 0.922)) // #EBEBEB
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, scrollBottomPadding)
                    })
                }
            }
            .overlay(alignment: .bottom) {
                if keyboardHeight == 0 {
                    saveTrainingButton
                }
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
                if !showingDatePicker && !showingTimePicker && !showingHorsePicker && !showingTypePicker && keyboardHeight == 0 {
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
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                withAnimation(.easeOut(duration: 0.25)) {
                    keyboardHeight = frame.height
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    keyboardHeight = 0
                }
            }
        )
    }

    /// Tab bar (83) + Save (50) + spacing; without keyboard overlays are visible.
    /// With keyboard: use trimmed keyboard height to avoid huge empty scroll (double inset with system).
    private var scrollBottomPadding: CGFloat {
        let safeAreaBottom = safeAreaBottomInset
        if keyboardHeight > 0 {
            let trimmed = keyboardHeight - safeAreaBottom - 28
            return max(64, min(trimmed, 260))
        }
        return 83 + 50 + 24 + safeAreaBottom
    }

    private var safeAreaBottomInset: CGFloat {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }) else {
            return 0
        }
        return window.safeAreaInsets.bottom
    }

    private var horseSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Horse:")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133))
                .padding(.bottom, 8)

            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 0) {
                    if showingHorsePicker {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("Select")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(Color(red: 0.627, green: 0.627, blue: 0.627))
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.top, 12)
                            .padding(.bottom, 12)

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
                                                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133))
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
                        HStack {
                            if let horse = selectedHorse {
                                Text(horse.name)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133))
                            } else {
                                Text("Select")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(Color(red: 0.627, green: 0.627, blue: 0.627))
                            }
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(Color(red: 0.627, green: 0.627, blue: 0.627))
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 30)
                    }
                }
                .frame(width: 358)
                .background(Color(red: 0.922, green: 0.922, blue: 0.922))
                .cornerRadius(8)

                if showingHorsePicker {
                    Button(action: {
                        playButtonSound()
                        showingHorsePicker = false
                    }) {
                        TriangleShape()
                            .stroke(Color(red: 0.627, green: 0.627, blue: 0.627), lineWidth: 1)
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
    }

    private var trainingTypeSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Training Type:")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133))
                .padding(.bottom, 8)

            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 0) {
                    if showingTypePicker {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("Select")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(Color(red: 0.627, green: 0.627, blue: 0.627))
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.top, 12)
                            .padding(.bottom, 12)

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
                                                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133))
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
                        HStack {
                            Text(selectedType.displayName)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133))
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(Color(red: 0.627, green: 0.627, blue: 0.627))
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 30)
                    }
                }
                .frame(width: 358)
                .background(Color(red: 0.922, green: 0.922, blue: 0.922))
                .cornerRadius(8)

                if showingTypePicker {
                    Button(action: {
                        playButtonSound()
                        showingTypePicker = false
                    }) {
                        TriangleShape()
                            .stroke(Color(red: 0.627, green: 0.627, blue: 0.627), lineWidth: 1)
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
    }

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Mood:")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133))
                .padding(.bottom, 8)

            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 0) {
                    if showingMoodPicker {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("Select")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(Color(red: 0.627, green: 0.627, blue: 0.627))
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.top, 12)
                            .padding(.bottom, 12)

                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(Array(Mood.allCases.enumerated()), id: \.element) { _, mood in
                                    Button(action: {
                                        playButtonSound()
                                        selectedMood = mood
                                        showingMoodPicker = false
                                    }) {
                                        HStack {
                                            Text("\(mood.emoji) \(mood.rawValue)")
                                                .font(.system(size: 14, weight: .regular))
                                                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133))
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
                        HStack {
                            if let mood = selectedMood {
                                Text("\(mood.emoji) \(mood.rawValue)")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133))
                            } else {
                                Text("Select")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(Color(red: 0.627, green: 0.627, blue: 0.627))
                            }
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(Color(red: 0.627, green: 0.627, blue: 0.627))
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 30)
                    }
                }
                .frame(width: 358)
                .background(Color(red: 0.922, green: 0.922, blue: 0.922))
                .cornerRadius(8)

                if showingMoodPicker {
                    Button(action: {
                        playButtonSound()
                        showingMoodPicker = false
                    }) {
                        TriangleShape()
                            .stroke(Color(red: 0.627, green: 0.627, blue: 0.627), lineWidth: 1)
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
    }

    private var saveTrainingButton: some View {
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

private struct DoneNumberField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.keyboardType = .numberPad
        textField.placeholder = placeholder
        textField.textColor = UIColor(red: 0.133, green: 0.133, blue: 0.133, alpha: 1.0)
        textField.font = .systemFont(ofSize: 14, weight: .regular)
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)

        // Wrapper avoids _UIToolbarContentView width/height == 0 during keyboard layout (Auto Layout warnings).
        let w = UIScreen.main.bounds.width
        let h: CGFloat = 44
        let accessory = UIView(frame: CGRect(x: 0, y: 0, width: w, height: h))
        accessory.backgroundColor = .clear
        accessory.autoresizingMask = [.flexibleWidth]

        let toolbar = UIToolbar(frame: accessory.bounds)
        toolbar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let flex = UIBarButtonItem(systemItem: .flexibleSpace)
        let done = UIBarButtonItem(title: "Done", style: .done, target: context.coordinator, action: #selector(Coordinator.doneTapped))
        toolbar.items = [flex, done]
        accessory.addSubview(toolbar)

        textField.inputAccessoryView = accessory

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            self._text = text
        }

        @objc func textChanged(_ sender: UITextField) {
            text = sender.text ?? ""
        }

        @objc func doneTapped() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if string.isEmpty { return true }
            return string.allSatisfy(\.isNumber)
        }
    }
}
