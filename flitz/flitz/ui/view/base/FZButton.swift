//
//  FZButton.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/15/24.
//

import SwiftUI

enum FZButtonSize {
    case textual
    case normal
    case large
}


struct FZButton<Content: View>: View {
    @Environment(\.colorScheme)
    var colorScheme: ColorScheme
    
    var palette: FZButtonPalette = .primary
    var size: FZButtonSize = .normal
    
    var action: () -> Void
    @ViewBuilder
    var label: () -> Content
    
    var isDisabled: Bool = false
    
    var body: some View {
        var backgroundColor = colorScheme == .light ?
            palette.lightBackground :
            palette.darkBackground
        
        var foregroundColor = colorScheme == .light ?
            palette.lightForeground :
            palette.darkForeground
        
        Button(action: action) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                label()
            }
            .font(.main)
            .if(size == .large) {
                $0
                    .frame(minHeight: 60)
                    .frame(maxWidth: .infinity)
            }
            .if(size == .normal) {
                $0.padding(.vertical, 8)
                  .padding(.horizontal, 24)
            }
            .background(isDisabled ? palette.disabledBackground : backgroundColor)
            .foregroundStyle(isDisabled ? foregroundColor.opacity(0.75) : foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            // .padding(16)
            
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
                FZButton(palette: .primary) {
                    print("Hello, World!")
                } label: {
                    Text("test")
                }
                Text("General")
            }
            VStack {
                FZButton(palette: .primary) {
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
                FZButton(palette: .primary) {
                    print("Hello, World!")
                } label: {
                    Image(systemName: "plus")
                    Text("Add")
                }
                Text("General")
            }
            VStack {
                FZButton(palette: .primary) {
                    print("Hello, World!")
                } label: {
                    Image(systemName: "minus")
                    Text("Remove")
                }
                .disabled(true)
                Text("Disabled")
            }
        }
        
        VStack {
            FZButton(size: .large) {
            } label: {
                Text("Hello, World!")
            }
        }
    }
}
