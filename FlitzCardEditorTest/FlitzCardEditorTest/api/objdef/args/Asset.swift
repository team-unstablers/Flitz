//
//  Card.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 12/1/24.
//

import Foundation

enum AssetCreationType {
    case image
    
    var defaultFileName: String {
        switch self {
        case .image:
            return "image.jpg"
        }
    }
    
    var mimeType: String {
        switch self {
        case .image:
            return "image/jpeg"
        }
    }
}

struct AssetCreationArgs {
    
}
