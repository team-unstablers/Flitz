//
//  CardListManage.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/5/25.
//

import SwiftUI

@MainActor
class CardManagerViewModel: ObservableObject {
    @Published
    var cards: [FZSimpleCard] = []
    
    @Published
    var selection: String?
    
    var client: FZAPIClient = RootAppState.shared.client
    
    /// 내 카드 목록을 가져옵니다.
    func fetchCards() async {
        do {
            let cards = try await self.client.cards()
            
            self.cards = cards.results
            self.selection = cards.results.first?.id
        } catch {
            // FIXME
            print(error)
        }
    }
    
    func newCard() async {
        do {
            let card = try await self.client.createCard()
            
            RootAppState.shared.navState.append(.cardEditor(cardId: card.id))
        } catch {
            print(error)
        }
    }
}


struct CardManagerView: View {
    @StateObject
    var viewModel = CardManagerViewModel()
    
    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FZButton(size: .large) {
                
            } label: {
                Text("새 카드 만들기")
            }
            
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.cards) { card in
                        VStack {
                            CardPreview(client: $viewModel.client, cardId: card.id)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .tag(card.id)
                        .cornerRadius(15)
                        .frame(width: 150, height: 200)
                        // .background(.init(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1))
                        .padding()
                    }
                }
            }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                Task {
                    await viewModel.fetchCards()
                }
            }

        /*
        TabView(selection: $viewModel.selection) {
            NewCardPreview {
                Task {
                    await viewModel.newCard()
                }
            }
                .tag("__NEW_CARD__")
            
            ForEach(viewModel.cards) { card in
                CardPreview(client: $viewModel.client, cardId: card.id)
                    .tag(card.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
         */
    }
    
}
