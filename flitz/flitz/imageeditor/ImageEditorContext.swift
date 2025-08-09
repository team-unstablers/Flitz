//
//  ImageEditorContext.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/7/25.
//

import Foundation
import SwiftUI
import BrightroomEngine

class ImageEditorContext {
    let editingStack: EditingStack
    private(set) public var rendered: BrightRoomImageRenderer.Rendered? = nil
    
    init(from imageProvider: ImageProvider) async {
        self.editingStack = EditingStack(imageProvider: imageProvider)
        
        // FIXME: 여기에 실패하는 케이스에 어떻게 대응해?
        await withCheckedContinuation { cont in
            self.editingStack.start {
                cont.resume()
            }
        }
    }
    
    convenience init(from image: UIImage) async {
        await self.init(from: ImageProvider(image: image))
    }
    
    convenience init(from data: Data) async throws {
        await self.init(from: try ImageProvider(data: data))
    }
    
    convenience init(from url: URL) async throws {
        await self.init(from: try ImageProvider(fileURL: url))
    }
    
    func render() throws {
        let renderer = try editingStack.makeRenderer()
        self.rendered = try renderer.render()
    }
}
