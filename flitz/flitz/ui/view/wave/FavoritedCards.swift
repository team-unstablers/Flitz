//
//  CardListManage.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/5/25.
//

import SwiftUI

@MainActor
class FavoritedCardsViewModel: ObservableObject {
    @Published
    var favorites: [FZCardFavoriteItem] = []
    
    @Published
    var renderCaches: [String: UIImage] = [:]
    
    var client: FZAPIClient = RootAppState.shared.client
    
    func fetchFavorites() async {
        do {
            let favorites = try await self.client.favoritedCards()
            
            // FIXME: support pagination
            self.favorites = favorites.results
            await prerenderCard()
        } catch {
            print(error)
        }
    }
    
    func prerenderCard() async {
        let renderer = FZCardViewSwiftUICardRenderer()
        
        await withTaskGroup { group in
            for favorite in self.favorites {
                group.addTask {
                    await self.prerenderCard(favorite.card, using: renderer)
                }
            }
        }
    }
    
    func prerenderCard(_ card: FZCard, using renderer: FZCardViewCardRenderer) async {
        let assetsLoader = AssetsLoader.global
        
        do {
            try await assetsLoader.resolveAll(from: card.content)
        } catch {
            print(error)
        }
        
        do {
            let mainTexture = try renderer.render(card: card.content, options: [])
            
            renderCaches[card.id] = mainTexture
        } catch {
            print("[CardManagerViewModel] Failed to prerender card \(card.id): \(error)")
        }
    }
    
}


struct FavoritedCards: View {
    @EnvironmentObject
    var appState: RootAppState

    @StateObject
    var viewModel = FavoritedCardsViewModel()
    
    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.favorites) { favorite in
                        Button {
                            appState.currentModal = .cardDetail(cardId: favorite.card.id)
                        } label: {
                            if let renderedCardImage = viewModel.renderCaches[favorite.card.id] {
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
                        .tag(favorite.id)
                        .cornerRadius(15)
                        .frame(width: 150, height: 200)
                        // .background(.init(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1))
                        .padding()
                        .contextMenu {
                            Button("카드 삭제하기") {
                                Task {
                                    do {
                                        try await viewModel.client.deleteFavoriteCard(by: favorite.id)
                                        await viewModel.fetchFavorites()
                                    } catch {
                                        print("Failed to delete favorite card: \(error)")
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
                    await viewModel.fetchFavorites()
                }
            }
    }
    
}
