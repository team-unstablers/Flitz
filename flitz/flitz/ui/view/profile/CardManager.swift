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
    var cardMetas: [FZSimpleCard] = []
    
    @Published
    var renderCaches: [String: UIImage] = [:]
    
    var client: FZAPIClient = RootAppState.shared.client
    
    /// 내 카드 목록을 가져옵니다.
    func fetchCards() async {
        do {
            let cardMetas = try await self.client.cards()
            
            self.cardMetas = cardMetas.results
            await prerenderCard()
        } catch {
            print(error)
        }
    }
    
    func prerenderCard() async {
        let assetsLoader = AssetsLoader.global
        let renderer = FZCardViewSwiftUICardRenderer()
        
        for cardMeta in self.cardMetas {
            do {
                let card = try await self.client.card(by: cardMeta.id)
                
                do {
                    try await assetsLoader.resolveAll(from: card.content)
                } catch {
                    print(error)
                }
                
                let mainTexture = try renderer.render(card: card.content)
                
                
                renderCaches[cardMeta.id] = mainTexture
            } catch {
                print("[CardManagerViewModel] Failed to prerender card \(cardMeta.id): \(error)")
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
            
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.cardMetas) { card in
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
                            } else {
                                // Placeholder while rendering
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            }
                        }
                        .buttonStyle(.plain)
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
    }
    
}
