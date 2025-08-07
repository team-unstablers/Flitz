//
//  MessageComposeArea.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/4/25.
//

import SwiftUI

struct MessageComposeArea: View {
    @State 
    private var text: String = ""
    
    @FocusState
    private var textFieldFocused: Bool
    
    var onSend: ((String) -> Void)?
    var onAttach: (() -> Void)?
    var isSending: Bool = false
    
    var body: some View {
        HStack(spacing: 8) {
            Button {
                onAttach?()
            } label: {
                Image(systemName: "photo")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(isSending)
            
            TextField("메시지를 입력하세요", text: $text, axis: .vertical)
                .lineLimit(1...3)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                // .disabled(isSending)
                .focused($textFieldFocused)
                .onSubmit {
                    sendMessage()
                }
            
            Button {
                sendMessage()
            } label: {
                if isSending {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                        .frame(width: 16, height: 16)
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                }
            }
            .padding(12)
            .background(text.isEmpty || isSending ? Color.gray : Color.blue)
            .clipShape(Circle())
            .buttonStyle(.plain)
            .disabled(text.isEmpty || isSending)
            .focusable(false)
        }
        .padding(.vertical)
        .padding(.horizontal, 8)
    }
    
    private func sendMessage() {
        guard !text.isEmpty else { return }
        let message = text
        text = ""
        onSend?(message)
        
        DispatchQueue.main.async {
            textFieldFocused = true
        }
    }
}

#Preview {
    MessageComposeArea()
}
