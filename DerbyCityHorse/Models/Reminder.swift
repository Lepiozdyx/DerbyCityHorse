//
//  Reminder.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import Foundation

struct Reminder: Identifiable, Codable {
    var id: UUID
    var horseId: UUID?
    var actionType: ActionType
    var date: Date
    var isCompleted: Bool
    
    init(id: UUID = UUID(), horseId: UUID? = nil, actionType: ActionType, date: Date, isCompleted: Bool = false) {
        self.id = id
        self.horseId = horseId
        self.actionType = actionType
        self.date = date
        self.isCompleted = isCompleted
    }
}
