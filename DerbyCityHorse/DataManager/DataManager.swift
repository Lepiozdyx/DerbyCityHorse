//
//  DataManager.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import Foundation

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var horses: [Horse] = []
    @Published var journalEntries: [JournalEntry] = []
    @Published var trainings: [Training] = []
    @Published var reminders: [Reminder] = []
    
    private let horsesKey = "horses"
    private let journalEntriesKey = "journalEntries"
    private let trainingsKey = "trainings"
    private let remindersKey = "reminders"
    
    private init() {
        loadData()
    }
    
    // MARK: - Horses
    func addHorse(_ horse: Horse) {
        horses.append(horse)
        saveHorses()
    }
    
    func updateHorse(_ horse: Horse) {
        if let index = horses.firstIndex(where: { $0.id == horse.id }) {
            horses[index] = horse
            saveHorses()
        }
    }
    
    func deleteHorse(_ horse: Horse) {
        horses.removeAll { $0.id == horse.id }
        journalEntries.removeAll { $0.horseId == horse.id }
        trainings.removeAll { $0.horseId == horse.id }
        reminders.removeAll { $0.horseId == horse.id }
        saveHorses()
        saveJournalEntries()
        saveTrainings()
        saveReminders()
    }
    
    // MARK: - Journal Entries
    func addJournalEntry(_ entry: JournalEntry) {
        journalEntries.append(entry)
        saveJournalEntries()
        
        // Auto-create reminders for actions
        if entry.actionType == .farrier || entry.actionType == .vet {
            // Create reminder for 2 days before next appointment (assuming monthly)
            if let nextDate = Calendar.current.date(byAdding: .month, value: 1, to: entry.date),
               let reminderDate = Calendar.current.date(byAdding: .day, value: -2, to: nextDate) {
                let reminder = Reminder(
                    horseId: entry.horseId,
                    actionType: entry.actionType,
                    date: reminderDate
                )
                addReminder(reminder)
            }
        } else if entry.actionType == .vitamins {
            // Create reminder for next day
            if let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: entry.date) {
                let reminder = Reminder(
                    horseId: entry.horseId,
                    actionType: entry.actionType,
                    date: nextDate
                )
                addReminder(reminder)
            }
        } else {
            // Create reminder for other actions (feeding, grooming, hoof care) for next day
            if let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: entry.date) {
                let reminder = Reminder(
                    horseId: entry.horseId,
                    actionType: entry.actionType,
                    date: nextDate
                )
                addReminder(reminder)
            }
        }
    }
    
    func deleteJournalEntry(_ entry: JournalEntry) {
        journalEntries.removeAll { $0.id == entry.id }
        saveJournalEntries()
    }
    
    func getJournalEntries(for horseId: UUID) -> [JournalEntry] {
        return journalEntries.filter { $0.horseId == horseId }.sorted { $0.date > $1.date }
    }
    
    // MARK: - Trainings
    func addTraining(_ training: Training) {
        trainings.append(training)
        saveTrainings()
    }
    
    func updateTraining(_ training: Training) {
        if let index = trainings.firstIndex(where: { $0.id == training.id }) {
            trainings[index] = training
            saveTrainings()
        }
    }
    
    func deleteTraining(_ training: Training) {
        trainings.removeAll { $0.id == training.id }
        saveTrainings()
    }
    
    func getTrainings(for horseId: UUID) -> [Training] {
        return trainings.filter { $0.horseId == horseId }.sorted { $0.date > $1.date }
    }
    
    func getAllTrainings() -> [Training] {
        return trainings.sorted { $0.date > $1.date }
    }
    
    // MARK: - Reminders
    func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
        saveReminders()
    }
    
    func updateReminder(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
            saveReminders()
        }
    }
    
    func deleteReminder(_ reminder: Reminder) {
        reminders.removeAll { $0.id == reminder.id }
        saveReminders()
    }
    
    func getActiveReminders() -> [Reminder] {
        return reminders.filter { !$0.isCompleted && $0.date >= Calendar.current.startOfDay(for: Date()) }
            .sorted { $0.date < $1.date }
    }
    
    // MARK: - Calendar
    func getEvents(for date: Date) -> [CalendarEvent] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        var events: [CalendarEvent] = []
        
        // Journal entries
        let entries = journalEntries.filter { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
        for entry in entries {
            events.append(.journal(entry))
        }
        
        // Trainings
        let dayTrainings = trainings.filter { training in
            calendar.isDate(training.date, inSameDayAs: date)
        }
        for training in dayTrainings {
            events.append(.training(training))
        }
        
        return events.sorted { $0.date < $1.date }
    }
    
    func getCalendarEvents(for date: Date) -> [CalendarEventType] {
        let calendar = Calendar.current
        var eventTypes: [CalendarEventType] = []
        
        // Check for trainings (blue)
        let hasTraining = trainings.contains { calendar.isDate($0.date, inSameDayAs: date) }
        if hasTraining {
            eventTypes.append(.training)
        }
        
        // Check for important events (red) - farrier, vet
        let hasImportant = journalEntries.contains { entry in
            calendar.isDate(entry.date, inSameDayAs: date) &&
            (entry.actionType == .farrier || entry.actionType == .vet)
        }
        if hasImportant {
            eventTypes.append(.important)
        }
        
        // Check for regular events (yellow) - feeding, grooming
        let hasRegular = journalEntries.contains { entry in
            calendar.isDate(entry.date, inSameDayAs: date) &&
            (entry.actionType == .feeding || entry.actionType == .grooming)
        }
        if hasRegular {
            eventTypes.append(.regular)
        }
        
        // Check for other events (green) - hoofCare, vitamins
        let hasOther = journalEntries.contains { entry in
            calendar.isDate(entry.date, inSameDayAs: date) &&
            (entry.actionType == .hoofCare || entry.actionType == .vitamins)
        }
        if hasOther {
            eventTypes.append(.other)
        }
        
        return eventTypes
    }
    
    // MARK: - Persistence
    private func loadData() {
        loadHorses()
        loadJournalEntries()
        loadTrainings()
        loadReminders()
    }
    
    private func saveHorses() {
        if let encoded = try? JSONEncoder().encode(horses) {
            UserDefaults.standard.set(encoded, forKey: horsesKey)
        }
    }
    
    private func loadHorses() {
        if let data = UserDefaults.standard.data(forKey: horsesKey),
           let decoded = try? JSONDecoder().decode([Horse].self, from: data) {
            horses = decoded
        }
    }
    
    private func saveJournalEntries() {
        if let encoded = try? JSONEncoder().encode(journalEntries) {
            UserDefaults.standard.set(encoded, forKey: journalEntriesKey)
        }
    }
    
    private func loadJournalEntries() {
        if let data = UserDefaults.standard.data(forKey: journalEntriesKey),
           let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            journalEntries = decoded
        }
    }
    
    private func saveTrainings() {
        if let encoded = try? JSONEncoder().encode(trainings) {
            UserDefaults.standard.set(encoded, forKey: trainingsKey)
        }
    }
    
    private func loadTrainings() {
        if let data = UserDefaults.standard.data(forKey: trainingsKey),
           let decoded = try? JSONDecoder().decode([Training].self, from: data) {
            trainings = decoded
        }
    }
    
    private func saveReminders() {
        if let encoded = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(encoded, forKey: remindersKey)
        }
    }
    
    private func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: remindersKey),
           let decoded = try? JSONDecoder().decode([Reminder].self, from: data) {
            reminders = decoded
        }
    }
}

// MARK: - Calendar Event Types
enum CalendarEventType: Hashable {
    case training
    case important // кузнец/ветеринар
    case regular // кормление/уход
    case other // уход за копытами/витамины
}

enum CalendarEvent {
    case journal(JournalEntry)
    case training(Training)
    
    var date: Date {
        switch self {
        case .journal(let entry):
            return entry.date
        case .training(let training):
            return training.date
        }
    }
}
