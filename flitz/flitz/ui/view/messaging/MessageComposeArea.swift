//
//  MessageComposeArea.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/4/25.
//

import SwiftUI

struct MessageComposeArea: View {
    @State
    var text: String = ""
    
    var body: some View {
        HStack(spacing: 8) {
            /*
            HStack {
                Image(systemName: "paperclip")
                Image(systemName: "camera")
                Image(systemName: "mic")
                Image(systemName: "hand.raised")
                Image(systemName: "ellipsis")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(20)
            .padding()
             */
            
            Button {
                print("Attach")
            } label: {
                Image(systemName: "photo")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            TextField("메시지를 입력하세요", text: $text, axis: .vertical)
                .lineLimit(1...3)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(20)
            
            Button {
                print("Send")
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(Color(.systemBlue))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical)
        .padding(.horizontal, 8)
    }
    
}

#Preview {
    MessageComposeArea()
}
