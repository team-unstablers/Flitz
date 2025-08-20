//
//  SimplecardPreview.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

struct CardPreview: View {
    @EnvironmentObject
    var appState: RootAppState
    
    @Environment(\.fzAssetsLoader)
    var assetsLoader: AssetsLoader
    
    @Binding
    var client: FZAPIClient
    
    var cardId: String
    
    /*
    @State
    var world: FZCardViewWorld = {
        let world = FZCardViewWorld()
        world.setup()
        
        return world
    }()
    */
    
    @State
    var showNormalMap: Bool = false
    
    @State
    var card: Flitz.Card?
    
    @State
    var cardMeta: FZCard?
    
    @State
    var renderedCardImage: UIImage? = nil
    
    var body: some View {
        VStack {
            if let renderedCardImage = renderedCardImage {
                Image(uiImage: renderedCardImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .frame(maxWidth: 400, maxHeight: 400)
                    .padding()
                    .shadow(color: .black.opacity(0.25), radius: 8)
            } else {
                ProgressView()
            }
            /*
            FZCardView(world: $world, enableGesture: false)
                .displayCard($card, to: $world, showNormalMap: $showNormalMap)
                .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 0)
             */
            /*
            
            VStack {
                Text(cardMeta?.title ?? "")
                    .font(.heading2)
                    .bold()
                HStack {
                    FZButton {
                        showNormalMap.toggle()
                    } label: {
                        Text("노멀 맵")
                    }
                    
                    FZButton {
                        appState.navState.append(.cardEditor(cardId: cardId))
                    } label: {
                        Text("편집하기")
                    }
                    
                    FZButton {
                        setCardAsMain()
                    } label: {
                        Text("메인 카드로 설정")
                    }
                }
            }
            .padding(.bottom, 32)
             */
        }
        .onAppear {
            self.fetchCard()
        }
    }
    
    func fetchCard() {
        Task {
            do {
                let card = try await client.card(by: cardId)
                do {
                    try await assetsLoader.resolveAll(from: card.content)
                } catch {
                    print(error)
                }
                
                DispatchQueue.main.async {
                    self.card = card.content
                    self.cardMeta = card
                    
                    self.renderContent()
                }
            } catch {
                print(error)
            }
        }
    }
    
    func setCardAsMain() {
        Task {
            do {
                try await client.setCardAsMain(which: cardId)
            } catch {
                print(error)
            }
        }
    }
    
    @MainActor
    func renderContent() {
        let renderer = FZCardViewSwiftUICardRenderer()
        
        guard let card = self.card,
              let mainTexture = try? renderer.render(card: card, options: []) else {
            print("Failed to render card")
            return
        }
        
        self.renderedCardImage = mainTexture
    }
}
