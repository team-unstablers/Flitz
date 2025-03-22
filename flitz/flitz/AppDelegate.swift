//
//  AppDelegate.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/15/24.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    static fileprivate(set) var apnsToken: String? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
        
        UNUserNotificationCenter.current().delegate = self
        
        UIFont.setupUINavigationBarTypography()
        

        return true
    }
    

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let stringifiedToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Self.apnsToken = stringifiedToken
        print("stringifiedToken:", stringifiedToken)
        
        RootAppState.shared.updateAPNSToken()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // This function allows us to view notifications in the app even with it in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        // These options are the options that will be used when displaying a notification with the app in the foreground
        // for example, we will be able to display a badge on the app a banner alert will appear and we could play a sound
        return [.badge, .banner, .list, .sound]
    }
    
    
    // This function lets us do something when the user interacts with a notification
    // like log that they clicked it, or navigate to a specific screen
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        // FIXME
    }
}
