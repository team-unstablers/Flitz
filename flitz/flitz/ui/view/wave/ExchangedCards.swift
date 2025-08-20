//
//  ExchangedCards.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/31/24.
//

import SwiftUI

struct ECController: View {
    var distributionId: String
    
    var dismissHandler: (String) -> Void
    
    var body: some View {
        HStack {
            Spacer()
            ECControlButton(size: .large) {
                Task {
                    try? await RootAppState.shared.client.markAsDislike(which: distributionId)
                }
                
                dismissHandler(distributionId)
            } content: {
                Image("ECSkip")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .padding(.top, 4)
            }
            
            Spacer()
            
            ECControlButton(size: .medium) {
                print("menu")
            } content: {
                Image("ECMenu")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)

            }
            
            Spacer()


            ECControlButton(size: .large) {
                Task {
                    // try? await RootAppState.shared.client.markAsLike(which: distributionId)
                }
                
                dismissHandler(distributionId)
            } content: {
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
            WaveCardManagerView()
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
