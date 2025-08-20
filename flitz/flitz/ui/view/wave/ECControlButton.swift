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
        Button {
            action()
        } label: {
            VStack {
                content()
            }
            .frame(width: size.size, height: size.size)
            .background(
                BlurEffectView(style: .light)
                    .clipShape(Circle())
            )
            .compositingGroup()
            .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 2)
            .hapticFeedback()
        }
    }
}

struct ECControlMenu<Label: View, Content: View>: View {
    var size: ECControlButtonSize = .large
    
    var content: () -> Content
    var label: () -> Label
    
    var body: some View {
        Menu {
            content()
        } label: {
            VStack {
                label()
            }
            .frame(width: size.size, height: size.size)
            .background(
                BlurEffectView(style: .light)
                    .clipShape(Circle())
            )
            .compositingGroup()
            .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 2)
            .hapticFeedback()
        }
    }
}

struct ECController: View {
    var distributionId: String
    
    var dismissHandler: (String) -> Void
    
    var body: some View {
        HStack {
            Spacer()
            ECControlButton(size: .large) {
                Task {
                    try? await RootAppState.shared.client.markAsDislike(which: distributionId)
                }
                
                dismissHandler(distributionId)
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
                Button("카드 신고하기", role: .destructive) {
                    print("TODO")
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
                    try? await RootAppState.shared.client.markAsLike(which: distributionId)
                }
                
                dismissHandler(distributionId)
            } content: {
                Image("ECHeart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .padding(.top, 4)
            }
            Spacer()
        }
    }
}

#Preview {
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
