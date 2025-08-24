//
//  CardEditor.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 12/1/24.
//

import SwiftUI

struct CardEditor: View {
    @EnvironmentObject
    var appState: RootAppState
    
    var cardId: String
    
    @Binding
    var client: FZAPIClient

    @State
    var card: FZCard?
    
    @State
    var assetsLoader: AssetsLoader = AssetsLoader()
    
    @State
    var isElementEditorPresented: Bool = false
    
    var body: some View {
        VStack {
            if let card = card {
                CardEditorInternal(card: card.content,
                                   isElementEditorPresented: $isElementEditorPresented)
                    .environment(\.fzAssetsLoader, assetsLoader)
            } else {
                EmptyView()
            }
        }
        .background(.black)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTransparent(true)
        .animation(.default, value: isElementEditorPresented)
        .toolbarVisibility(isElementEditorPresented ? .hidden : .visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("저장") {
                    self.saveCard()
                }
            }
        }
        .onAppear {
            self.fetchCard()
        }
    }
    
    
    func fetchCard() {
        Task {
            do {
                let card = try await client.card(by: cardId)
                try? await self.assetsLoader.resolveAll(from: card.content)
                
                DispatchQueue.main.async {
                    self.card = card
                }
            } catch {
                print(error)
            }
        }
    }
    
    func saveCard() {
        guard var card = card else { return }
        card.title = "test"
        
        Task {
            do {
                try await client.uploadCardAssets(of: card)
                let card = try await client.patchCard(which: card)
                try? await self.assetsLoader.resolveAll(from: card.content)

                DispatchQueue.main.async {
                    self.card = card
                    appState.navState = []
                }
            } catch {
                print(error)
            }
        }
    }
}
