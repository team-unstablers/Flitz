//
//  RelativeTime.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/2/25.
//

import Foundation

extension Date {
    var relativeTime: String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(self)
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
        formatter.maximumUnitCount = 1
        return formatter.string(from: timeInterval) ?? ""
    }
}
