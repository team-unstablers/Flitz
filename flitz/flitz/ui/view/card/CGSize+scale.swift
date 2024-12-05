//
//  CGSize+scale.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import CoreGraphics

extension CGSize {
    func aspectScaled(toFit size: CGSize) -> CGFloat {
        let scale = min(size.width / width, size.height / height)
        return scale
    }
}
