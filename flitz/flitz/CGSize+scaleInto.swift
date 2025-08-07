//
//  CGSize+scaleInto.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/8/25.
//

import CoreGraphics

extension CGSize {
    func scaleInto(target targetSize: CGSize) -> CGSize {
        let widthScale = targetSize.width / width
        let heightScale = targetSize.height / height
        let scale = min(widthScale, heightScale)
        
        return CGSize(width: width * scale, height: height * scale)
    }
}
