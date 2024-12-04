//
//  CardListScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

struct CardListScreen: View {
    @EnvironmentObject
    var appState: RootAppState
    
    @State
    var cards: [FZSimpleCard] = []
    
    var body: some View {
        VStack {
            TabView {
                ForEach(cards, id: \.id) { card in
                    SimpleCardPreview(client: $appState.client, cardId: card.id)
                }
            }
            .tabViewStyle(.page)
        }
        .navigationTitle("My Cards")
        .onAppear {
            self.fetchSelfCards()
        }
    }
    
    func fetchSelfCards() {
        Task {
            do {
                let cards = try await self.appState.client.cards()
                
                DispatchQueue.main.async {
                    self.cards = cards.results
                }
            } catch {
                print(error)
            }
        }
    }
}
