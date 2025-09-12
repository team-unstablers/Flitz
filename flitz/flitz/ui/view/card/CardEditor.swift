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
    var initialBusy: Bool = true
    
    @State
    var busy: Bool = false

    @State
    var card: FZCard?
    
    @State
    var assetsLoader: AssetsLoader = AssetsLoader()
    
    @State
    var isElementEditorPresented: Bool = false
    
    var body: some View {
        ZStack {
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
            
            if initialBusy {
                VStack(spacing: 6) {
                    Text(NSLocalizedString("ui.card.editor.loading.title", comment: "불러오는 중"))
                        .font(.fzHeading3)
                        .semibold()
                        .foregroundStyle(.white)
                    
                    Text(NSLocalizedString("ui.card.editor.loading.message", comment: "잠시만 기다려 주세요..."))
                        .font(.fzMain)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black.opacity(0.5))
            }
            
            if busy {
                VStack(spacing: 6) {
                    Text(NSLocalizedString("ui.card.editor.saving.title", comment: "저장 중"))
                        .font(.fzHeading3)
                        .semibold()
                        .foregroundStyle(.white)

                    Text(NSLocalizedString("ui.card.editor.saving.message", comment: "잠시만 기다려 주세요..."))
                        .font(.fzMain)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black.opacity(0.5))
            }
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTransparent(true)
        .animation(.default, value: isElementEditorPresented)
        .animation(.default, value: busy)
        .animation(.default, value: initialBusy)
        .toolbarVisibility(isElementEditorPresented ? .hidden : .visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if busy {
                    ProgressView()
                } else {
                    Button(NSLocalizedString("ui.card.editor.action.save", comment: "저장")) {
                        self.saveCard()
                    }
                }
            }
        }
        .onAppear {
            self.fetchCard()
        }
    }
    
    
    func fetchCard() {
        Task {
            defer { initialBusy = false }
            
            if cardId == "__NEW__" {
                let cardContent = Flitz.Card(
                    version: .v1,
                    background: nil,
                    elements: [],
                    properties: [:]
                )
                
                let now = Date().ISO8601Format()
                
                self.card = FZCard(id: "__NEW__",
                                   title: "Untitled",
                                   content: cardContent,
                                   created_at: now,
                                   updated_at: now)
                return
            }
            
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
    
        Task {
            defer { busy = false }
            busy = true
            
            do {
                if card.id == "__NEW__" {
                    let newCard = try await self.client.createCard()
                    
                    card.id = newCard.id
                    card.title = newCard.title
                    card.created_at = newCard.created_at
                    card.updated_at = newCard.updated_at
                }
                
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
