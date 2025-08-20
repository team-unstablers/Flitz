//
//  ExchangedCards.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/31/24.
//

import SwiftUI




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
