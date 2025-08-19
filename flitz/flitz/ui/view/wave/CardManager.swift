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
    var cards: [FZCard] = []
    
    @Published
    var renderCaches: [String: UIImage] = [:]
    
    var client: FZAPIClient = RootAppState.shared.client
    
    /// 내 카드 목록을 가져옵니다.
    func fetchCards() async {
        do {
            let cards = try await self.client.cards()
            
            self.cards = cards.results
            await prerenderCard()
        } catch {
            print(error)
        }
    }
    
    func prerenderCard() async {
        let assetsLoader = AssetsLoader.global
        let renderer = FZCardViewSwiftUICardRenderer()
        
        for card in self.cards {
            do {
                do {
                    try await assetsLoader.resolveAll(from: card.content)
                } catch {
                    print(error)
                }
                
                let mainTexture = try renderer.render(card: card.content)
                
                renderCaches[card.id] = mainTexture
            } catch {
                print("[CardManagerViewModel] Failed to prerender card \(card.id): \(error)")
            }
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
    @EnvironmentObject
    var appState: RootAppState

    @StateObject
    var viewModel = CardManagerViewModel()
    
    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FZButton(size: .large) {
                Task {
                    await viewModel.newCard()
                }
            } label: {
                Text("새 카드 만들기")
            }
                .padding(16)
            
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.cards) { card in
                        Button {
                            appState.currentModal = .cardDetail(cardId: card.id)
                        } label: {
                            if let renderedCardImage = viewModel.renderCaches[card.id] {
                                // Rendered card image is available
                                Image(uiImage: renderedCardImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .padding()
                                    .shadow(color: .black.opacity(0.25), radius: 8)
                                    .contentShape(RoundedRectangle(cornerRadius: 6))
                            } else {
                                // Placeholder while rendering
                                VStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                }
                                    .frame(width: 150, height: 200)
                                    .contentShape(RoundedRectangle(cornerRadius: 6))
                            }
                        }
                        .buttonStyle(.plain)
                        .tag(card.id)
                        .cornerRadius(15)
                        .frame(width: 150, height: 200)
                        // .background(.init(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1))
                        .padding()
                        .contextMenu {
                            Button("카드 편집하기") {
                                appState.navState.append(.cardEditor(cardId: card.id))
                            }
                            
                            Button("메인 카드로 설정") {
                                Task {
                                    do {
                                        try await viewModel.client.setCardAsMain(which: card.id)
                                        await viewModel.fetchCards()
                                    } catch {
                                        print("Failed to set main card: \(error)")
                                    }
                                }
                            }
                            
                            Button("카드 삭제하기") {
                                Task {
                                    do {
                                        try await viewModel.client.deleteCard(by: card.id)
                                        await viewModel.fetchCards()
                                    } catch {
                                        print("Failed to delete card: \(error)")
                                    }
                                }
                            }
                        }
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
    }
    
}
