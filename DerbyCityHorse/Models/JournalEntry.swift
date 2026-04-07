//
//  JournalEntry.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import Foundation

struct JournalEntry: Identifiable, Codable {
    var id: UUID
    var horseId: UUID
    var actionType: ActionType
    var date: Date
    
    init(id: UUID = UUID(), horseId: UUID, actionType: ActionType, date: Date = Date()) {
        self.id = id
        self.horseId = horseId
        self.actionType = actionType
        self.date = date
    }
}
