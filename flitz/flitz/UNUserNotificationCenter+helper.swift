//
//  UNUserNotificationCenter+helper.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/5/25.
//

import UserNotifications

extension UNUserNotificationCenter {
    static fileprivate(set) var granted = false
    static func setup() {
        current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error)")
                return
            }
            
            self.granted = granted
        })
    }
}
