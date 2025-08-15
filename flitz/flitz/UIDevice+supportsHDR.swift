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
        UIScreen.main.traitCollection.displayGamut == .P3
    }
}
