//
//  ActionType.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import Foundation

enum ActionType: String, Codable, CaseIterable {
    case feeding = "feeding"
    case grooming = "grooming"
    case hoofCare = "hoofCare"
    case vitamins = "vitamins"
    case farrier = "farrier"
    case vet = "vet"
    
    var emoji: String {
        switch self {
        case .feeding: return "🥕"
        case .grooming: return "🧼"
        case .hoofCare: return "🐴"
        case .vitamins: return "💊"
        case .farrier: return "🛠️"
        case .vet: return "🏥"
        }
    }
    
    var displayName: String {
        switch self {
        case .feeding: return "Feeding"
        case .grooming: return "Grooming"
        case .hoofCare: return "Hoof Care"
        case .vitamins: return "Vitamins"
        case .farrier: return "Farrier"
        case .vet: return "Veterinarian"
        }
    }
}
