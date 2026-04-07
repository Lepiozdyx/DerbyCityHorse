//
//  ButtonSound.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import SwiftUI
import AudioToolbox

func playButtonSound() {
    AudioServicesPlaySystemSound(1104) // Системный звук кнопки iOS
}

extension View {
    func withButtonSound(_ action: @escaping () -> Void) -> some View {
        Button(action: {
            playButtonSound()
            action()
        }) {
            self
        }
    }
}
