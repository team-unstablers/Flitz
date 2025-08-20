import SwiftUI
import UIKit

extension View {
    /// Adds haptic feedback when touching in and out
    /// - Parameters:
    ///   - inStyle: The haptic feedback style when touching down (default: light)
    ///   - outStyle: The haptic feedback style when releasing touch (default: light)
    /// - Returns: A view with haptic feedback on touch
    func hapticFeedback(
        in inStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light,
        out outStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light
    ) -> some View {
        self.modifier(HapticFeedbackModifier(inStyle: inStyle, outStyle: outStyle))
    }
}

private struct HapticFeedbackModifier: ViewModifier {
    let inStyle: UIImpactFeedbackGenerator.FeedbackStyle
    let outStyle: UIImpactFeedbackGenerator.FeedbackStyle
    
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            // .scaleEffect(isPressed ? 0.95 : 1.0)
            .onLongPressGesture(
                minimumDuration: .infinity,
                maximumDistance: .infinity,
                pressing: { pressing in
                    if pressing != isPressed {
                        isPressed = pressing
                        
                        let style = pressing ? inStyle : outStyle
                        let generator = UIImpactFeedbackGenerator(style: style)
                        generator.prepare()
                        generator.impactOccurred()
                    }
                },
                perform: {}
            )
    }
}

// Convenience methods for common patterns
extension View {
    /// Adds light haptic feedback on both touch down and release
    func hapticFeedback() -> some View {
        self.hapticFeedback(in: .light, out: .light)
    }
    
    /// Adds haptic feedback only when touching down
    func hapticFeedbackOnTouchDown(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.modifier(HapticFeedbackOnTouchDownModifier(style: style))
    }
    
    /// Adds haptic feedback only when releasing touch
    func hapticFeedbackOnTouchUp(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.modifier(HapticFeedbackOnTouchUpModifier(style: style))
    }
}

private struct HapticFeedbackOnTouchDownModifier: ViewModifier {
    let style: UIImpactFeedbackGenerator.FeedbackStyle
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            // .scaleEffect(isPressed ? 0.95 : 1.0)
            .onLongPressGesture(
                minimumDuration: .infinity,
                maximumDistance: .infinity,
                pressing: { pressing in
                    if pressing && !isPressed {
                        let generator = UIImpactFeedbackGenerator(style: style)
                        generator.prepare()
                        generator.impactOccurred()
                    }
                    isPressed = pressing
                },
                perform: {}
            )
    }
}

private struct HapticFeedbackOnTouchUpModifier: ViewModifier {
    let style: UIImpactFeedbackGenerator.FeedbackStyle
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .onLongPressGesture(
                minimumDuration: .infinity,
                maximumDistance: .infinity,
                pressing: { pressing in
                    if !pressing && isPressed {
                        let generator = UIImpactFeedbackGenerator(style: style)
                        generator.prepare()
                        generator.impactOccurred()
                    }
                    isPressed = pressing
                },
                perform: {}
            )
    }
}
