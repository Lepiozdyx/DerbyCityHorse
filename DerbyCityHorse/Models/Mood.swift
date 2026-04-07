//
//  Mood.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import Foundation

enum Mood: String, Codable, CaseIterable {
    case calm = "Calm"
    case excited = "Excited"
    case tired = "Tired"
    case playful = "Playful"
    
    var emoji: String {
        switch self {
        case .calm: return "😌"
        case .excited: return "🤪"
        case .tired: return "😴"
        case .playful: return "😄"
        }
    }
}
