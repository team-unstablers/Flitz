//
//  CardListScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

/// @Deprecated
struct CardListScreen: View {
    @EnvironmentObject
    var appState: RootAppState
    
    @State
    var cards: [FZSimpleCard] = []
    
    var body: some View {
        NavigationView {
            TabView {
                ForEach(cards, id: \.id) { card in
                    SimpleCardPreview(client: $appState.client, cardId: card.id)
                }
            }
            .tabViewStyle(.page)
            .toolbarTitleDisplayMode(.inline)
            .navigationTitle("My Cards")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New Card") {
                        self.createNewCard()
                    }
                }
            }
        }
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
    
    func createNewCard() {
        Task {
            do {
                let card = try await self.appState.client.createCard()
                
                DispatchQueue.main.async {
                    self.appState.navState.append(.cardEditor(cardId: card.id))
                }
            } catch {
                print(error)
            }
        }
    }
}
