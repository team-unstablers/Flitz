//
//  FZCardViewCardRenderer.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/25/24.
//

import Foundation

import UIKit
import SwiftUI

protocol FZCardViewCardRenderer {
    @MainActor
    func render(card: Flitz.Card) throws -> UIImage
    
    @MainActor
    func renderNormalMap(card: Flitz.Card) throws -> UIImage
}

extension FZCardViewCardRenderer {
}
