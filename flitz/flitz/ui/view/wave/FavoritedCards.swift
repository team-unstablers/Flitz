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
    
    @Published var hasMoreData = true
    
    private var currentPage: Paginated<FZCardFavoriteItem>?
    private var isLoading = false
    
    var client: FZAPIClient = RootAppState.shared.client
    
    func fetchFavorites() async {
        guard !isLoading else { return }
        
        isLoading = true
        do {
            let page = try await self.client.favoritedCards()
            self.currentPage = page
            self.favorites = page.results
            self.hasMoreData = page.next != nil
            await prerenderCard()
        } catch {
            print(error)
        }
        isLoading = false
    }
    
    func loadMore() async {
        guard let currentPage = currentPage,
              let nextUrl = currentPage.next,
              !isLoading else { return }
        
        isLoading = true
        do {
            guard let page = try await client.nextPage(currentPage) else {
                return
            }
            self.currentPage = page
            
            let newFavorites = page.results
            self.favorites.append(contentsOf: newFavorites)
            self.hasMoreData = page.next != nil
            
            // Prerender only new cards
            let renderer = FZCardViewSwiftUICardRenderer()
            await withTaskGroup { group in
                for favorite in newFavorites {
                    group.addTask {
                        await self.prerenderCard(favorite.card, using: renderer)
                    }
                }
            }
        } catch {
            print("[FavoritedCardsViewModel] Failed to load more favorites: \(error)")
        }
        isLoading = false
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
            FZInfiniteGridView(
                data: viewModel.favorites,
                columns: columns,
                hasMoreData: $viewModel.hasMoreData,
                spacing: 0,
                onLoadMore: {
                    await viewModel.loadMore()
                }
            ) { index, favorite in
                Button {
                    // 컨텍스트 메뉴가 동작해야 해서 disabled() 대신 핸들러 차원에서 막는다
                    if index >= 6 {
                        return
                    }
                    
                    appState.currentModal = .cardDetail(cardId: favorite.card.id)
                } label: {
                    if let renderedCardImage = viewModel.renderCaches[favorite.card.id] {
                        // Rendered card image is available
                        VStack {
                            Image(uiImage: renderedCardImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .padding()
                                .shadow(color: .black.opacity(0.25), radius: 8)
                                .contentShape(RoundedRectangle(cornerRadius: 6))
                            if let user = favorite.card.user {
                                HStack(spacing: 4) {
                                    ProfileImage(url: user.profile_image_url, userId: user.id, size: 24)
                                    
                                    Text(user.display_name)
                                        .semibold()
                                        .lineLimit(1)
                                }
                            }
                        }
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
                .blur(radius: index >= 6 ? 5 : 0)
                .contextMenu {
                    Button(NSLocalizedString("ui.wave.favorites.context.remove", comment: "보관함에서 삭제하기"), role: .destructive) {
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
            .refreshable {
                await viewModel.fetchFavorites()
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
