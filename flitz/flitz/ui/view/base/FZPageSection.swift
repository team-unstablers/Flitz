//
//  FZPageSection.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/10/25.
//

import SwiftUI

struct FZPageSectionLargeDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.Grayscale.gray1)
            .frame(maxWidth: .infinity, maxHeight: 12)
    }
}

struct FZPageSectionDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.Grayscale.gray2)
            .frame(maxWidth: .infinity, maxHeight: 1)
            .padding(.vertical, 12)
    }
}

struct FZPageSectionTitle: View {
    var title: String
    
    var body: some View {
        VStack {
            Text(title)
                .foregroundStyle(Color.Grayscale.gray6)
                .font(.fzMain)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: 44)
    }
}

struct FZPageSectionItem<Content: View>: View {
    var title: String
    
    @ViewBuilder
    var content: () -> Content
    
    
    init(_ title: String, content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(title)
                .foregroundStyle(Color.Brand.black0)
                .font(.fzHeading3)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            VStack(spacing: 0) {
                content()
            }
        }
        .frame(minHeight: 48)
        .contentShape(Rectangle())
    }
}

struct FZPageSectionActionItem: View {
    var title: String
    var action: () -> Void
    
    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                Text(title)
                    .foregroundStyle(Color.Brand.black0)
                    .font(.fzHeading3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 48)
            .contentShape(Rectangle())
        }
            .buttonStyle(PlainButtonStyle())
    }
}
    
 
struct FZPageSectionActionItemWithSubtitle: View {
    var title: String
    var subtitle: String
    
    var action: () -> Void
    
    init(_ title: String, subtitle: String, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 4) {
                Text(title)
                    .foregroundStyle(Color.Brand.black0)
                    .font(.fzHeading3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(subtitle)
                    .foregroundStyle(Color.Grayscale.gray8)
                    .font(.fzSmall)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 48)
            .contentShape(Rectangle())
        }
            .buttonStyle(PlainButtonStyle())
    }
}
    
 
