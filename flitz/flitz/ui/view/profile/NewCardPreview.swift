//
//  SimplecardPreview.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

struct NewCardPreview: View {
    var action: () -> Void
    
    var body: some View {
        VStack {
            DummyCardView()
                .overlay {
                    Button {
                        action()
                    } label: {
                        VStack(spacing: 12) {
                            Group {
                                Image(systemName: "plus")
                                    .font(.system(size: 64))
                                Text(NSLocalizedString("ui.profile.new_card.create", comment: "새 카드 만들기"))
                                    .font(.heading2)
                                    .bold()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.5))
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10])))
                        .padding()
                    }
                    .buttonStyle(.plain)
                }
            VStack {}
                .padding(.bottom, 32)
            
        }
    }
}


#Preview {
    NewCardPreview {
        
    }
}
