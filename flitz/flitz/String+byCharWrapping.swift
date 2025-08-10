//
//  String+byCharWrapping.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/11/25.
//

import Foundation

extension String {
    var byCharWrapping: Self {
        map(String.init).joined(separator: "\u{200B}")
    }
}
