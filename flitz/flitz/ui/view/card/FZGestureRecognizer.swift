//
//  FZGestureRecognizer.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 12/1/24.
//

import Foundation

import UIKit
import SwiftUI

typealias FZGestureHandler<T> = (UIGestureRecognizer.State, T) -> Void

fileprivate class FZGestureRecognizerInternalDelegate: NSObject, UIGestureRecognizerDelegate {
    static let shared = FZGestureRecognizerInternalDelegate()
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}


struct FZMagnifyGestureRecognizer: UIGestureRecognizerRepresentable {
    var handler: FZGestureHandler<CGFloat>
    
    func makeUIGestureRecognizer(context: Context) -> UIPinchGestureRecognizer {
        let recognizer = UIPinchGestureRecognizer()
        
        recognizer.delegate = FZGestureRecognizerInternalDelegate.shared
        
        return recognizer
    }
    
    func handleUIGestureRecognizerAction(_ recognizer: UIPinchGestureRecognizer, context: Context) {
        
        
        switch recognizer.state {
        case .began:
            print("began")
        case .changed:
            break
        case .ended:
            print("ended")
        case .cancelled:
            print("cancelled")
        case .failed:
            print("failed")
        case .possible:
            print("possible")
        default:
            print("unknown")
        }
        
        
        if (recognizer.state == .ended) {
            recognizer.reset()
        }
        handler(recognizer.state, recognizer.scale)
    }
}

struct FZRotationGestureRecognizer: UIGestureRecognizerRepresentable {
    var handler: FZGestureHandler<CGFloat>
    
    func makeUIGestureRecognizer(context: Context) -> UIRotationGestureRecognizer {
        let recognizer = UIRotationGestureRecognizer()
        
        recognizer.delegate = FZGestureRecognizerInternalDelegate.shared

        return recognizer
    }
    
    func handleUIGestureRecognizerAction(_ recognizer: UIRotationGestureRecognizer, context: Context) {
        handler(recognizer.state, recognizer.rotation.rad2deg)
    }
}

struct FZDragGestureRecognizer: UIGestureRecognizerRepresentable {
    var handler: FZGestureHandler<CGPoint>
    
    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let recognizer = UIPanGestureRecognizer()
        
        recognizer.delegate = FZGestureRecognizerInternalDelegate.shared

        return recognizer
    }
    
    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context: Context) {
        handler(recognizer.state, recognizer.translation(in: recognizer.view))
    }
}
