//
//  FZEntry.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/14/25.
//

import SwiftUI

struct FZEntry<Content: View>: View {
    let label: String
    
    @ViewBuilder
    let content: () -> Content
    
    @FocusState
    private var isFocused: Bool
    
    init(_ label: String, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.fzSmall)
            
            content()
                .focused($isFocused)
        }
            .padding(12)
            .cornerRadius(10)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isFocused ? Color.black : Color.Grayscale.gray3, lineWidth: 1)
                    .animation(.spring, value: isFocused)
            }
    }
}

struct FZInlineEntry<Content: View>: View {
    let label: String
    
    @ViewBuilder
    let content: () -> Content
    
    @FocusState
    private var isFocused: Bool
    
    init(_ label: String, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.fzMain)
                .foregroundStyle(Color.Brand.black0)
                .padding(.bottom, 20)
            
            content()
                .focused($isFocused)
            Rectangle()
                .frame(height: 1)
                .animation(.spring, value: isFocused)
                .foregroundStyle(isFocused ? Color.Brand.black0 : Color.Grayscale.gray2)
        }
    }
}
