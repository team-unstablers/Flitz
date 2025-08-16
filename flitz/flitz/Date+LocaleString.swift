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
    
    var localeDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }
}
