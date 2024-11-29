//
//  TestView.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/29/24.
//

import SwiftUI

struct TestSignInView: View {
    @Binding
    var phase: Bool
    
    @State
    var username = ""
    
    @State
    var password = ""
    
    var body: some View {
        VStack {
            TextField("username", text: $username)
                .autocorrectionDisabled(true)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            SecureField("password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            Button("signin") {
                self.performSignIn()
            }
        }
        .padding()
    }
    
    func performSignIn() {
        let client = FZAPIClient(context: FZAPIContext())
        let credentials = FZCredentials(username: self.username, password: self.password, device_info: "FlitzCardEditorTest.app")
        
        Task {
            do {
                let token = try await client.authorize(with: credentials)
                var context = FZAPIContext()
                context.token = token.token
                
                FZAPIContext.stored = context
                
                DispatchQueue.main.async {
                    self.phase = true
                }
            } catch {
                print(error)
            }
        }
    }
}

struct TestView: View {
    enum AppRootNavState: Hashable {
        case cardPreview(String)
        case cardEditor(String)
    }
    
    var client = FZAPIClient(context: FZAPIContext.stored!)
    
    @State
    var profile: FZUser? = nil
    
    @State
    var cards: [FZSimpleCard] = []
    
    @State
    var navState: [AppRootNavState] = []
    
    var body: some View {
        NavigationStack(path: $navState) {
            VStack {
                if let profile = profile {
                    Text("Hello, \(profile.username)")
                }
                
                List {
                    ForEach(cards) { card in
                        Button {
                            navState.append(.cardPreview(card.id))
                        } label: {
                            VStack {
                                Text(card.title)
                                Text(card.updated_at)
                            }
                        }
                    }
                }
            }
            .onAppear {
                self.fetchSelfProfile()
                self.fetchSelfCards()
            }
            .navigationDestination(for: AppRootNavState.self) { state in
                switch state {
                case .cardEditor(let cardID):
                    Text("CardEditor \(cardID)")
                case .cardPreview(let cardId):
                    CardPreviewTest(cardId: cardId)
                }
            }
        }
    }
    
    func fetchSelfProfile() {
        Task {
            do {
                let profile = try await self.client.fetchUser(id: "self")
                
                DispatchQueue.main.async {
                    self.profile = profile
                }
            } catch {
                print(error)
            }
        }
    }
    
    func fetchSelfCards() {
        Task {
            do {
                let cards = try await self.client.cards()
                
                DispatchQueue.main.async {
                    self.cards = cards.results
                }
            } catch {
                print(error)
            }
        }
    }
}
