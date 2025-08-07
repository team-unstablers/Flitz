//
//  RelativeTime.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/2/25.
//

import Foundation

extension Date {
    var localeTimeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }
}
