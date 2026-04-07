//
//  Training.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import Foundation

struct Training: Identifiable, Codable {
    var id: UUID
    var horseId: UUID
    var date: Date
    var duration: Int // в минутах
    var type: TrainingType
    var notes: String
    var mood: Mood
    
    init(id: UUID = UUID(), horseId: UUID, date: Date, duration: Int, type: TrainingType, notes: String, mood: Mood) {
        self.id = id
        self.horseId = horseId
        self.date = date
        self.duration = duration
        self.type = type
        self.notes = notes
        self.mood = mood
    }
}
