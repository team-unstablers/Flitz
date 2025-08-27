//
//  UIImage+toSRGB.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/27/25.
//


import CoreGraphics

extension CGImage {
    func convertColorSpace(to colorSpace: CFString) -> CGImage {
        guard let cs = CGColorSpace(name: colorSpace),
        let ctx = CGContext(data: nil, width: width, height: height,
                            bitsPerComponent: 8, bytesPerRow: 0,
                            space: cs,
                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else {
            print("Failed to create color space or context")
            return self
        }
        
        ctx.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let convertedImage = ctx.makeImage() else {
            print("Failed to create image from context")
            return self
        }
        
        return convertedImage
    }
    
}
