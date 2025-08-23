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
    
    @Published var hasMoreData = true
    
    private var currentPage: Paginated<FZCard>?
    private var isLoading = false
    
    var client: FZAPIClient = RootAppState.shared.client
    
    /// 내 카드 목록을 가져옵니다.
    func fetchCards() async {
        guard !isLoading else { return }
        
        isLoading = true
        do {
            let page = try await self.client.cards()
            self.currentPage = page
            self.cards = page.results
            self.hasMoreData = page.next != nil
            await prerenderAllCards()
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
            
            let newCards = page.results
            self.cards.append(contentsOf: newCards)
            self.hasMoreData = page.next != nil
            
            // Prerender only new cards
            let renderer = FZCardViewSwiftUICardRenderer()
            await withTaskGroup { group in
                for card in newCards {
                    group.addTask {
                        await self.prerenderCard(card, using: renderer)
                    }
                }
            }
        } catch {
            print("[CardManagerViewModel] Failed to load more cards: \(error)")
        }
        isLoading = false
    }
    
    func prerenderAllCards() async {
        let renderer = FZCardViewSwiftUICardRenderer()
        
        await withTaskGroup { group in
            for card in self.cards {
                group.addTask {
                    await self.prerenderCard(card, using: renderer)
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
            
            FZInfiniteGridView(
                data: viewModel.cards,
                columns: columns,
                hasMoreData: $viewModel.hasMoreData,
                spacing: 0,
                onLoadMore: {
                    await viewModel.loadMore()
                }
            ) { card in
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
            .refreshable {
                await viewModel.fetchCards()
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
