//
//  FZCardViewCardRenderer.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/25/24.
//

import Foundation

import UIKit
import SwiftUI

struct FZCardViewCardRendererOptions: OptionSet {
    let rawValue: Int
    
    static let renderNormalMap = FZCardViewCardRendererOptions(rawValue: 1 << 0)
    static let renderBlurry    = FZCardViewCardRendererOptions(rawValue: 1 << 1)
}

protocol FZCardViewCardRenderer {
    @MainActor
    func render(card: Flitz.Card, options: FZCardViewCardRendererOptions) throws -> UIImage
}

extension FZCardViewCardRenderer {
}
