//
//  ContentView.swift
//  FlitzCardTest
//
//  Created by Gyuhwan Park on 11/19/24.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    static let backgroundGradient: Gradient = Gradient(colors: [
        Color(r8: 255, g8: 235, b8: 76),
        Color(r8: 255, g8: 203, b8: 50)
    ])
    
    static let backgroundGradient2: Gradient = Gradient(colors: [
        Color(hex: 0xffffff),
        Color(hex: 0xF2F2F2)
    ])

    @State
    var anim: Bool = false
    
    @State
    var text: String = "텍스트를 입력하십시오"
    
    var cardContent: some View {
        let bgImageUrl = Bundle.main.url(forResource: "image1", withExtension: "jpg")!
        let bgImage = UIImage(contentsOfFile: bgImageUrl.path)!

        return VStack {
            Text("Hello, world!")
                .bold()
                .padding(4)
                .background(.white)
                .clipShape(.rect(cornerRadius: 4))
            
            Text(text)
                .bold()
                .padding(4)
                .background(.white)
                .clipShape(.rect(cornerRadius: 4))
        }
        .frame(width: 512, height: 512)
        .background {
            Image(uiImage: bgImage)
                .resizable()
        }
    }

    var body: some View {
        VStack {
            VStack {
                GeometryReader { geom in
                    FlitzCardView("card_base_2_tmp", cardContent)
                        .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 0)
                        .offset(x: 0, y: anim ? 0 : geom.size.height)
                }
            }
            .background {
                LinearGradient(gradient: Self.backgroundGradient2, startPoint: .top, endPoint: .bottom)
            }
            .clipShape(.rect(cornerRadius: 16))

            VStack {
                cardContent
                TextField("텍스트를 입력하십시오", text: $text)
                    .padding()
                    .background(.white)
                    .clipShape(.rect(cornerRadius: 4))
            }
            .padding()
        }
        .padding()
        .background {
            LinearGradient(gradient: Self.backgroundGradient, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.spring(duration: 0.75, bounce: 0.3)) {
                self.anim = true
            }
        }
    }
}

#Preview {
    ContentView()
}
