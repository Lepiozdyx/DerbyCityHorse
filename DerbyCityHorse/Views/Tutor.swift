//
//  Tutor.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import SwiftUI

struct Tutor: View {
    @State var screen: Int = 1
    @State var play: Bool = false
    @AppStorage("hasSeenTutor") private var hasSeenTutor = false

    var body: some View {
        GeometryReader { geometry in
            let width = max(geometry.size.width, 0)
            let height = max(geometry.size.height, 0)
            let scale = min(width / 390.0, height / 844.0)
            // Avoid negative width when layout is not ready (prevents CoreGraphics NaN spam).
            let textWidth = max(0, min(358.0 * scale, width - 32))
            let imageHeight = max(0, 478.0 * scale)

            ZStack {
                VStack(spacing: 0) {
                    Image("kon-\(screen)")
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: imageHeight)
                        .clipped()
                        .cornerRadius(35 * scale, corners: [.bottomLeft, .bottomRight])

                    VStack(spacing: 4 * scale) {
                        Text(onboardingTitle)
                            .font(.system(size: 32 * scale, weight: .bold))
                            .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133))
                            .multilineTextAlignment(.center)
                            .frame(width: textWidth)

                        Text(onboardingSubtitle)
                            .font(.system(size: 24 * scale, weight: .regular))
                            .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133))
                            .multilineTextAlignment(.center)
                            .frame(width: textWidth)
                    }
                    .padding(.top, 14 * scale)

                    Spacer(minLength: 0)

                    Button(action: {
                        playButtonSound()
                        if screen < 3 {
                            screen += 1
                        } else {
                            hasSeenTutor = true
                            play = true
                        }
                    }) {
                        Image("b-\(screen)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: textWidth, height: 50 * scale)
                    }
                    
                    Button("Skip") {
                        playButtonSound()
                        hasSeenTutor = true
                        play = true
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.627, green: 0.627, blue: 0.627))
                    .padding(.top, 10)
                    .padding(.bottom, max(16, (24 * scale) + geometry.safeAreaInsets.bottom))
                }
                .frame(width: width, height: height, alignment: .top)
                .background(Color.white.ignoresSafeArea())
            }
        }
        .fullScreenCover(isPresented: $play) {
            ContentView()
        }
        .ignoresSafeArea(edges: .top)
    }

    private var onboardingTitle: String {
        switch screen {
        case 1: return "Derby Care. Pure Class."
        case 2: return "Track Every Ride."
        default: return "Never Miss a Detail."
        }
    }

    private var onboardingSubtitle: String {
        switch screen {
        case 1:
            return "A smart offline diary for horse care and training. Everything organized and under control."
        case 2:
            return "Log trainings, mood, and progress, all in one place, day by day."
        default:
            return "Care routines, reminders, and horse health - always on time."
        }
    }
}

#Preview {
    Tutor()
}
