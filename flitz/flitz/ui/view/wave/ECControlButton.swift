//
//  ECControlButton.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/31/24.
//

import SwiftUI

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
            .background(.white)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(Color.gray_4A4A4A, lineWidth: 2)
            }
            .compositingGroup()
            .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 4)
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
