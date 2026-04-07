//
//  CustomHeaderView.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import SwiftUI

struct CustomHeaderView: View {
    let title: String
    let showBackButton: Bool
    let onBack: (() -> Void)?
    
    init(title: String, showBackButton: Bool = true, onBack: (() -> Void)? = nil) {
        self.title = title
        self.showBackButton = showBackButton
        self.onBack = onBack
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Rectangle 4 - 88px высота, белый фон с тенью
            ZStack(alignment: .top) {
                Color.white
                    .frame(height: 88)
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 2)
                
                // Group 1 - 44px высота, начинается с 44px от верха
                VStack {
                    Spacer()
                        .frame(height: 44)
                    
                    // Frame 33 - кнопка назад и название слева
                    HStack(spacing: 8) {
                        if showBackButton, let onBack = onBack {
                            // Кнопка назад - 7x14px, border 2px solid #222222
                            Button(action: {
                                playButtonSound()
                                onBack()
                            }) {
                                TriangleShape()
                                    .stroke(Color(red: 0.133, green: 0.133, blue: 0.133), lineWidth: 2)
                                    .frame(width: 7, height: 14)
                                    .scaleEffect(x: 1, y: -1) // Переворот по вертикали
                            }
                        }
                        
                        // Название - 20px, bold, цвет #222222
                        Text(title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133))
                    }
                    .frame(height: 44)
                    .padding(.leading, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 88)
            }
            
            // Линия внизу заголовка
            Rectangle()
                .fill(Color(red: 0.133, green: 0.133, blue: 0.133).opacity(0.1))
                .frame(height: 1)
        }
    }
}

struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return path
    }
}
