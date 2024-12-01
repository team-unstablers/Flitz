//
//  CardEditor.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 12/1/24.
//

import SwiftUI

struct CardEditor: View {
    var cardId: String
    
    @State
    var card: Flitz.Card?
    
    var body: some View {
        VStack {
            if let card = card {
                CardEditorInternal(card: card)
            } else {
                EmptyView()
            }
        }.onAppear {
            self.fetchCard()
        }
    }
    
    
    func fetchCard() {
        let client = FZAPIClient(context: FZAPIContext.stored!)
        Task {
            do {
                let card = try await client.card(by: cardId)
                
                DispatchQueue.main.async {
                    self.card = card.content
                }
            } catch {
                print(error)
            }
        }
    }
}
