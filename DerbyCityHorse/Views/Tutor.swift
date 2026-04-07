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
    var body: some View {
        GeometryReader{geometry in
            ZStack{
                VStack{
                    
                    
                    Image("kon-\(screen)")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width)
                    Spacer()
                    
                    Button(action: {
                        playButtonSound()
                        if(screen<3){
                            screen+=1
                        }else{
                            play = true
                        }
                    }) {
                        Image("b-\(screen)")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width * 0.9)
                    }
                    .padding(.bottom ,50)
                }
                .ignoresSafeArea()
            }
            .fullScreenCover(isPresented: $play) {
                ContentView()
            }
        }
    }
}

#Preview {
    Tutor()
}
