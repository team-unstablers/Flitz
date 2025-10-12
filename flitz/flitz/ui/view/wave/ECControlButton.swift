//
//  ECControlButton.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/31/24.
//

import SwiftUI
import SwiftUIX

enum ECControlButtonSize {
    case small
    case medium
    case large
    
    var size: CGFloat {
        switch self {
        case .small:
            return 36
        case .medium:
            return 48
        case .large:
            return 80
        }
    }
}

struct ECControlButton<Content: View>: View {
    var size: ECControlButtonSize = .large
    
    var action: () -> Void
    var content: () -> Content
    
    var body: some View {
        if #available (iOS 26.0, *) {
            Button {
                action()
            } label: {
                VStack {
                    content()
                }
                .frame(width: size.size, height: size.size)
            }
            .glassEffect(.regular, in: Circle())
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 2)
            .hapticFeedback()
        } else {
            Button {
                action()
            } label: {
                VStack {
                    content()
                }
                .frame(width: size.size, height: size.size)
                .background(
                    BlurEffectView(style: .light)
                        .background(.white.opacity(0.3))
                        .clipShape(Circle())
                )
                .compositingGroup()
                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 2)
                .hapticFeedback()
            }
        }

    }
}

struct ECControlMenu<Label: View, Content: View>: View {
    var size: ECControlButtonSize = .large
    
    var content: () -> Content
    var label: () -> Label
    
    var body: some View {
        if #available (iOS 26.0, *) {
            Menu {
                content()
            } label: {
                VStack {
                    label()
                }
                .frame(width: size.size, height: size.size)
                // BUG: iOS 26에서, Menu 자체에 .glassEffect(..., in: Circle())를 적용해도 메뉴를 닫을 때 일시적으로 clipShape가 적용되지 않음
                .glassEffect(.regular, in: Circle())
            }
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 2)
            .hapticFeedback()
        } else {
            Menu {
                content()
            } label: {
                VStack {
                    label()
                }
                .frame(width: size.size, height: size.size)
                .background(
                    BlurEffectView(style: .light)
                        .background(.white.opacity(0.3))
                        .clipShape(Circle())
                )
                .compositingGroup()
                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 2)
                .hapticFeedback()
            }
        }
    }
}

struct ECController: View {
    var distribution: FZCardDistribution
    
    var dismissHandler: (String) -> Void
    
    @State
    var isFlagSheetVisible: Bool = false
    
    var body: some View {
        HStack {
            Spacer()
            ECControlButton(size: .large) {
                Task {
                    await dislike()
                }
            } content: {
                Image("ECSkip")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .padding(.top, 4)
            }
            
            Spacer()
            
            ECControlMenu(size: .medium) {
                // TODO: icon
                Button(NSLocalizedString("ui.wave.card.context.report", comment: "카드 신고하기"), role: .destructive) {
                    isFlagSheetVisible = true
                }
            } label: {
                Image("ECMenu")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
            }
            
            Spacer()


            ECControlButton(size: .large) {
                Task {
                    await like()
                }
            } content: {
                Image("ECHeart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .padding(.top, 4)
            }
            Spacer()
        }
        .sheet(isPresented: $isFlagSheetVisible) {
            CardFlagSheet(cardId: distribution.card.id, userId: distribution.card.user!.id) {
                isFlagSheetVisible = false
            } submitAction: { blocked in
                Task {
                    await self.dislike()
                }
                isFlagSheetVisible = false
            }
        }
    }
    
    @MainActor
    func dislike() async {
        try? await RootAppState.shared.client.markAsDislike(which: distribution.id)
        dismissHandler(distribution.id)
    }
    
    @MainActor
    func like() async {
        try? await RootAppState.shared.client.markAsLike(which: distribution.id)
        dismissHandler(distribution.id)
    }
}

#Preview {
    VStack {
        ECControlButton(size: .large) {
            
        } content: {
            Image("ECHeart")
                .resizable()
                .scaledToFit()
                .frame(width: 40)
                .padding(.top, 4)
        }
        
        ECControlButton(size: .large) {
            
        } content: {
            Image("ECSkip")
                .resizable()
                .scaledToFit()
                .frame(width: 40)
                .padding(.top, 4)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.blue)
    
}
