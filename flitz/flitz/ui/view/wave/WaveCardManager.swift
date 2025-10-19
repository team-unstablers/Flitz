//
//  CardListManage.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/5/25.
//

import SwiftUI
import SwiftUIX

@MainActor
class WaveCardManagerViewModel: ObservableObject {
    @Published
    var distributions: [FZCardDistribution] = []
    
    @Published
    var cardInstances: [FZCardViewCardInstance] = []
    
    var current: FZCardDistribution? {
        distributions.first
    }
    
    @Published
    var selection: String?
    
    @Published
    var world: FZCardViewWorld
    
    var client: FZAPIClient = RootAppState.shared.client
    
    init() {
        self.world = FZCardViewWorld()
        self.world.setup()
    }
    
    /// 내 카드 목록을 가져옵니다.
    func fetchDistributions() async {
        await self.clearCards()
        
        do {
            let distributions = try await self.client.receivedCards()
            
            self.distributions = distributions.results
            self.selection = distributions.results.first?.id
            
            await self.spawnCards()
        } catch {
            // FIXME
            print(error)
        }
    }
    
    func clearCards() async {
        for instance in self.cardInstances {
            instance.destroy()
        }
        
        self.cardInstances.removeAll()
    }
    
    func spawnCards() async {
        let assetsLoader = AssetsLoader.global
        
        for distribution in distributions {
            let cardInstance = self.world.spawn(card: distribution.card.content, forId: distribution.id)
            
            cardInstance.shouldDisplayBlurry = distribution.reveal_phase != .revealed
            
            try? await assetsLoader.resolveAll(from: distribution.card.content)
            cardInstance.updateContent()
            
            self.cardInstances.append(cardInstance)
        }
    }
    
    func pop() {
        guard let current = self.current else {
            return
        }
        
        self.world.pop()
        self.distributions.removeAll { $0.id == current.id }
        self.cardInstances.removeAll { $0.id == current.id }
    }
        
}

struct WaveCardNoticeBox<Content: View>: View {
    
    @ViewBuilder
    var content: () -> Content
    
    var body: some View {
        if #available (iOS 26.0, *) {
            VStack() {
                content()
            }
            .padding()
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.24), radius: 16)
            .padding(.bottom, 32)
        } else {
            VStack() {
                content()
            }
            .padding()
            .background {
                BlurEffectView(style: .extraLight)
            }
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.24), radius: 16)
            .padding(.bottom, 32)
        }
    }
}

struct WaveCardNotRevealed: View {
    var body: some View {
        WaveCardNoticeBox {
            Text(NSLocalizedString("ui.wave.not_ready.title", comment: "아직은 카드를 볼 수 없어요"))
                .font(.heading2)
                .bold()
                .foregroundStyle(Color.Grayscale.gray8)
            
            Text(NSLocalizedString("ui.wave.not_ready.message", comment: "시간이 지나면 카드를 보을 수 있게 될 거에요.\n조금만 기다려 주세요!"))
                .multilineTextAlignment(.center)
                .font(.main)
                .foregroundStyle(Color.Grayscale.gray7)
        }
    }
}

struct WaveMainCardNotExists: View {
    var body: some View {
        WaveCardNoticeBox {
            Text(NSLocalizedString("ui.wave.main_card_not_exists.title", comment: "아직 메인 카드가 없어요"))
                .font(.heading2)
                .bold()
                .foregroundStyle(Color.Grayscale.gray8)
            
            Text(NSLocalizedString("ui.wave.main_card_not_exists.message", comment: "메인 카드가 없으면 다른 사람의 카드를 받을 수 없어요.\n'내 카드' 탭에서 메인 카드를 설정해 주세요!"))
                .multilineTextAlignment(.center)
                .font(.main)
                .foregroundStyle(Color.Grayscale.gray7)
        }
    }
}

struct WaveCardPreview: View {
    @EnvironmentObject
    var appState: RootAppState
    
    @Environment(\.fzAssetsLoader)
    var assetsLoader: AssetsLoader
    
    @StateObject
    var viewModel: WaveCardManagerViewModel
    
    @StateObject
    var profileGeometryHelper = UserProfileModalBodyGeometryHelper()
    
    @State
    var shouldHideController: Bool = false
    
    var profileOffsetY: CGFloat {
        profileGeometryHelper.size.height - profileGeometryHelper.contentAreaSize.height - profileGeometryHelper.profileImageAreaSize.height
    }

    var body: some View {
        if let distribution = viewModel.current {
            ZStack(alignment: .bottom) {
                ZStack(alignment: .bottom) {
                    FZCardView(world: viewModel.world, enableGesture: true)
#if DEBUG
                        .onTapGesture(count: 2) {
                            viewModel.cardInstances.first?.showNormalMap.toggle()
                            viewModel.cardInstances.first?.updateContent()
                        }
#endif
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { _ in
                                    shouldHideController = true
                                }
                                .onEnded { _ in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        shouldHideController = false
                                    }
                                }
                        )
                        .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 0)
                }
                .padding(.bottom, profileOffsetY)

                // 이거 여기가 아니라 부모에 있어야 됨
                if distribution.reveal_phase == .revealed {
                    ECController(distribution: distribution) { _ in
                        viewModel.pop()
                    }
                    .opacity(shouldHideController ? 0 : 1)
                    .animation(.easeInOut(duration: 0.3), value: shouldHideController)
                    .offset(x: 0, y: -(profileOffsetY + 30))
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                    
                    if let user = distribution.card.user {
                        BlurEffectView(style: .regular)
                            .opacity(profileGeometryHelper.opacity)
                        CollapseableUserProfile(
                            profile: user,
                            dismiss: nil,
                            profileGeometryHelper: profileGeometryHelper
                        )
                        
                        if #available(iOS 26.0, *) {
                            VStack(spacing: 0) {
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.0),
                                        .white.opacity(1.0),
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .frame(maxWidth: .infinity, maxHeight: 16)
                                Rectangle()
                                    .fill(.white)
                                    .ignoresSafeArea(.container)
                                    .frame(maxWidth: .infinity, maxHeight: .zero)
                            }
                        }
                    }
                }
                
                if distribution.reveal_phase == .blurry {
                    WaveCardNotRevealed()
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
                }
            }
                .animation(.easeInOut(duration: 0.3), value: distribution.reveal_phase)
        }
    }
}


struct WaveCardManagerView: View {
    @EnvironmentObject
    var appState: RootAppState
    
    @StateObject
    var viewModel = WaveCardManagerViewModel()
    
    var body: some View {
        VStack {
            if viewModel.distributions.isEmpty {
                ZStack(alignment: .bottom) {
                    NoCardsAvailable(reason: .noCardsExchanged)
                   
                    if let profile = appState.profile,
                       profile.main_card_id == nil {
                        WaveMainCardNotExists()
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .bottom).combined(with: .opacity)
                            ))
                    }
                }
            } else {
                WaveCardPreview(viewModel: viewModel)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchDistributions()
            }
        }
    }
}
