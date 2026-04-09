//
//  ButtonSound.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import SwiftUI
import AudioToolbox
import AVFoundation

final class ButtonSoundPlayer {
    static let shared = ButtonSoundPlayer()

    private var player: AVAudioPlayer?

    private init() {}

    func prepare() {
        guard player == nil else { return }
        guard let url = Bundle.main.url(forResource: "button", withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
        } catch {
            player = nil
        }
    }

    func play() {
        if player == nil {
            prepare()
        }

        if let player {
            player.currentTime = 0
            player.play()
        } else {
            // Fallback for cases where custom sound is unavailable.
            AudioServicesPlaySystemSound(1104)
        }
    }
}

func playButtonSound() {
    ButtonSoundPlayer.shared.play()
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
