//
//  ExchangedCards.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/31/24.
//

import SwiftUI

struct ECController: View {
    var body: some View {
        HStack {
            Spacer()
            ECControlButton(size: .large) {
                Image("ECSkip")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .padding(.top, 4)
            }
            
            Spacer()
            
            ECControlButton(size: .medium) {
                Image("ECMenu")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)

            }
            
            Spacer()


            ECControlButton(size: .large) {
                Image("ECHeart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .padding(.top, 4)
            }
            Spacer()
        }
    }
}


struct ExchangedCards: View {
    var body: some View {
        VStack {
            DummyCardView()
                .shadow(radius: 8)
                .background(.white)
            
            ECController()
                .offset(x: 0, y: -60)
        }
    }
}


#Preview {
    VStack(spacing: 0) {
        MainTitlebar {
            EmptyView()
        }
        ExchangedCards()
    }
}
