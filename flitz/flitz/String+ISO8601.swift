//
//  String+ISO8601.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/8/25.
//

import Foundation

extension String {
    var asISO8601Date: Date? {
        let fmt = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
        return try? fmt.parse(self)
    }
}
