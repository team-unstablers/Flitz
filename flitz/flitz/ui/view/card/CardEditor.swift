//
//  CardEditor.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 12/1/24.
//

import SwiftUI

struct CardEditor: View {
    var cardId: String
    
    @Binding
    var client: FZAPIClient

    @State
    var card: FZCard?
    
    @State
    var assetsLoader: AssetsLoader = AssetsLoader()
    
    var body: some View {
        VStack {
            if let card = card {
                CardEditorInternal(card: card.content)
                    .environment(\.fzAssetsLoader, assetsLoader)
            } else {
                EmptyView()
            }
            
            HStack {
                Button("save") {
                    self.saveCard()
                }
            }
        }.onAppear {
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
                }
            } catch {
                print(error)
            }
        }
    }
}
