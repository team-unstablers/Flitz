//
//  AppDelegate+UNUserNotificationCenterDelegate.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/10/25.
//

import Foundation
import UIKit
import UserNotifications

fileprivate extension UNNotificationPresentationOptions {
    static let all: UNNotificationPresentationOptions = [.badge, .banner, .list, .sound]
    static let none: UNNotificationPresentationOptions = []
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // This function allows us to view notifications in the app even with it in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let appState = RootAppState.shared
        let currentTab = appState.currentTab
        let navState = appState.navState
        
        let currentScreen = navState.last
        
        let userInfo = notification.request.content.userInfo
        let type = userInfo["type"] as? String ?? "unknown"
        
        if type == "message" {
            let conversationId = userInfo["conversation_id"] as? String ?? "__UNKNOWN__"
            
            let shouldNotDisplay = (
                (currentTab == .messages && currentScreen == nil) ||
                currentScreen == .conversation(conversationId: conversationId)
            )
            
            if shouldNotDisplay {
                appState.conversationUpdated.send()
                return .none
            }
        }
        
        // These options are the options that will be used when displaying a notification with the app in the foreground
        // for example, we will be able to display a badge on the app a banner alert will appear and we could play a sound
        return .all
    }
    
    
    // This function lets us do something when the user interacts with a notification
    // like log that they clicked it, or navigate to a specific screen
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        // FIXME
    }
}
