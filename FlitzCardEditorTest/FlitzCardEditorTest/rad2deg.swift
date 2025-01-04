//
//  rad2deg.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 12/1/24.
//

import Foundation

func deg2rad(_ number: Float) -> Float {
    return number * .pi / 180
}

func rad2deg(_ number: Float) -> Float {
    return number * 180 / .pi
}

extension CGFloat {
    var deg2rad: CGFloat {
        return self * .pi / 180
    }
    
    var rad2deg: CGFloat {
        return self * 180 / .pi
    }
}
