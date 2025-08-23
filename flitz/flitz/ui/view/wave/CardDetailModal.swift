//
//  MyCardDetailModal.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/9/25.
//

import SwiftUI
import SwiftUIX

@MainActor
class CardDetailModalViewModel: ObservableObject {
    var apiClient: FZAPIClient? = nil
    var cardId: String
   
    @Published
    var card: FZCard? = nil
    
    init(cardId: String) {
        self.cardId = cardId
    }
    
    func configure(with apiClient: FZAPIClient) {
        self.apiClient = apiClient
    }
    
    func loadCard() async {
        guard let apiClient = apiClient else { return }
        
        do {
            self.card = try await apiClient.card(by: cardId)
        } catch {
            print("[MyCardDetailModalViewModel] Failed to load card: \(error)")
        }
    }
    
    func deleteCard() async {
        guard let apiClient = apiClient else { return }
        
        do {
            try await apiClient.deleteCard(by: cardId)
            // Optionally, handle post-deletion logic
        } catch {
            print("[MyCardDetailModalViewModel] Failed to delete card: \(error)")
        }
    }
    
    func setCardAsMain() async {
        guard let apiClient = apiClient else { return }
        
        do {
            try await apiClient.setCardAsMain(which: cardId)
        } catch {
            print("[MyCardDetailModalViewModel] Failed to set card as main: \(error)")
        }
    }
}

struct CardDetailModalBackdrop: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.5))
            BlurEffectView(style: .regular)
        }
            .edgesIgnoringSafeArea(.all)
    }
}

struct CardDetailModal: View {
    @EnvironmentObject
    var appState: RootAppState

    var cardId: String
    var onDismiss: (() -> Void)? = nil
    
    @StateObject
    var viewModel: MyCardDetailModalViewModel
    
    @State private var dragOffset: CGSize = CGSize(width: 0, height: 300)
    @State private var opacity: Double = 0.0
    
    

    init(cardId: String, onDismiss: (() -> Void)? = nil, viewModel: MyCardDetailModalViewModel? = nil) {
        self.cardId = cardId
        self.onDismiss = onDismiss
        
        self._viewModel = StateObject(wrappedValue: viewModel ?? MyCardDetailModalViewModel(cardId: cardId))
    }

    var body: some View {
        GeometryReader { geom in
            ZStack(alignment: .center) {
                CardDetailModalBackdrop()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(opacity)
                    .onTapGesture {
                        withAnimation {
                            self.dismiss()
                        }
                    }
                
                if let card = viewModel.card {
                    WaveCardPreviewEx(cardMeta: $viewModel.card)
                        .frame(maxHeight: geom.size.height * 0.6)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .offset(y: max(0, dragOffset.height))
                        .opacity(opacity)
                        .simultaneousGesture(
                            DragGesture()
                            /*
                             .updating($dragOffset) { value, state, txn in
                             if value.translation.height > 0 {
                             state = value.translation
                             }
                             }
                             */
                                .onChanged { value in
                                    if (value.translation.height > 0) {
                                        dragOffset = value.translation
                                    } else {
                                        dragOffset = CGSize(width: 0, height: value.translation.height * 0.25)
                                    }
                                    
                                    let progress = min(1.0, max(0, value.translation.height / 300))
                                    opacity = 1.0 - (progress * 0.5)
                                }
                                .onEnded { value in
                                    if value.translation.height > 150 {
                                        self.dismiss()
                                    } else {
                                        withAnimation(.spring()) {
                                            opacity = 1.0
                                            dragOffset = .zero
                                        }
                                    }
                                }
                        )
                        .onAppear {
                            withAnimation(.spring()) {
                                opacity = 1.0
                                dragOffset = .zero
                            }
                        }
                    
                    VStack {
                        Spacer()
                        if let user = viewModel.card?.user {
                            CollapseableUserProfile(profile: user) {
                                self.dismiss()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(opacity)
                }
            }
        }
        
        .ignoresSafeArea(.all)
        .onAppear {
            viewModel.configure(with: appState.client)
            
            Task {
                await viewModel.loadCard()
            }
        }
        .onChange(of: cardId) {
            Task {
                await viewModel.loadCard()
            }
        }
    }
    
    @ViewBuilder
    func debug(_ message: String) -> some View {
        print(message)
        
        return EmptyView()
    }
    
    func dismiss() {
        withAnimation(.spring()) {
            opacity = 0
            dragOffset = CGSize(width: 0, height: 300)
        } completion: {
            onDismiss?()
        }
    }
}

#if DEBUG

class CardDetailModalViewModelPreview: MyCardDetailModalViewModel {
    override func loadCard() async {
        // Mock user data for preview
        // self.profile = FZUser.mock1
    }
}

#endif

#Preview {
    ZStack {
        Text("test\ntest\ntest\ntest\ntest\ntest\ntest\ntest")
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
        /*
        UserProfileModal(userId: "test", viewModel: UserProfileModalViewModelPreview(userId: "test"))
            .environmentObject(RootAppState())
         */
    }
}
