//
//  View+KeyboardPadding.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/13/25.
//
import SwiftUI
import Combine

extension View {
    @ViewBuilder
    func keyboardPadding() -> some View {
        self.modifier(KeyboardPaddingModifier())
    }
}

struct KeyboardPaddingModifier: ViewModifier {
    @State private var kb: CGFloat = 0
    func body(content: Content) -> some View {
        GeometryReader { geom in
            content
                .padding(.bottom, kb)
                .animation(.easeOut(duration: 0.25), value: kb)
                .onReceive(NotificationCenter.default.publisher(
                    for: UIResponder.keyboardWillChangeFrameNotification
                ).merge(with: NotificationCenter.default.publisher(
                    for: UIResponder.keyboardWillHideNotification
                ))) { note in
                    guard
                        let end = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                    else { return }
                    let screen = UIScreen.main.bounds
                    // 화면 하단 기준으로 키보드가 차지하는 높이
                    
                    kb = max(0, screen.maxY - end.minY - geom.safeAreaInsets.bottom)
                }
        }
    }
}
