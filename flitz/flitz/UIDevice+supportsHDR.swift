//
//  UIDevice+supportsHDR.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/16/25.
//

import Foundation
import UIKit

extension UIDevice {
    static var supportsHDR: Bool {
        return UIScreen.main.potentialEDRHeadroom > 1.0
    }
    
    static var supportsXDR: Bool {
        return UIScreen.main.potentialEDRHeadroom >= 4.0
    }
}
