//
//  TrainingType.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import Foundation

enum TrainingType: String, Codable, CaseIterable {
    case warmup = "Warmup"
    case dressage = "Dressage"
    case obstacles = "Obstacles"
    case freeRide = "Free Ride"
    
    var displayName: String {
        switch self {
        case .warmup: return "Warm-up"
        case .dressage: return "Dressage"
        case .obstacles: return "Obstacles"
        case .freeRide: return "Free Ride"
        }
    }
}
