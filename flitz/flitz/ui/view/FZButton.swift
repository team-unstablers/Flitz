//
//  FZButton.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/15/24.
//

import SwiftUI

enum FZButtonStyle {
    case general
    
    case custom(background: Color, foreground: Color)
    
    var backgroundColor: Color {
        switch self {
        case .general:
            return Color.Grayscale.gray8
        case .custom(let background, _):
            return background
        }
    }
    
    var disabledBackgroundColor: Color {
        switch self {
        case .general:
            return Color.Grayscale.gray4
        case .custom(let background, _):
            return background.opacity(0.5)
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .general:
            return .white
        case .custom(_, let foreground):
            return foreground
        }
    }
}

struct FZButton<Content: View>: View {
    
    var style: FZButtonStyle = .general
    
    var action: () -> Void
    @ViewBuilder
    var label: () -> Content
    
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                label()
            }
            .font(.main)
            .fontWeight(.medium)
            .padding(.vertical, 8)
            .padding(.horizontal, 24)
            .background(isDisabled ? style.disabledBackgroundColor : style.backgroundColor)
            .foregroundStyle(style.foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .disabled(isDisabled)
    }
    
    func disabled(_ isDisabled: Bool) -> Self {
        var copy = self
        copy.isDisabled = isDisabled
        return copy
    }
}

#Preview {
    VStack {
        Text("Text Only")
            .font(.heading1)
            .bold()
        
        HStack {
            VStack {
                FZButton(style: .general) {
                    print("Hello, World!")
                } label: {
                    Text("test")
                }
                Text("General")
            }
            VStack {
                FZButton(style: .general) {
                    print("Hello, World!")
                } label: {
                    Text("test")
                }
                .disabled(true)
                Text("Disabled")
            }
        }
        
        
        Text("With Icon")
            .font(.heading1)
            .bold()
        
        HStack {
            VStack {
                FZButton(style: .general) {
                    print("Hello, World!")
                } label: {
                    Image(systemName: "plus")
                    Text("Add")
                }
                Text("General")
            }
            VStack {
                FZButton(style: .general) {
                    print("Hello, World!")
                } label: {
                    Image(systemName: "minus")
                    Text("Remove")
                }
                .disabled(true)
                Text("Disabled")
            }
        }
        
        Text("Custom Style")
            .font(.heading1)
            .bold()
        
        HStack {
            VStack {
                FZButton(style: .custom(background: Color.Brand.yellow0, foreground: Color.Grayscale.gray7)) {
                } label: {
                    Image(systemName: "globe")
                    Text("번역")
                }
                Text("brand.yellow0")
                    .monospaced()
            }
            VStack {
                FZButton(style: .custom(background: Color.Subcolor.red, foreground: .white)) {
                    print("Hello, World!")
                } label: {
                    Image(systemName: "trash")
                    Text("삭제")
                }
                Text("subcolor.red")
                    .monospaced()
            }
        }
    }
}
