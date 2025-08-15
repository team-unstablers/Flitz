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
        
        recoverWaveCommunicatorState()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let stringifiedToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Self.apnsToken = stringifiedToken
        print("stringifiedToken:", stringifiedToken)
        
        RootAppState.shared.updateAPNSToken()
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("silent push received", userInfo)
        
        defer { completionHandler(.newData) }
        
        guard let type = userInfo["type"] as? String else {
            return
        }
        
        switch type {
        case "wake_up":
            recoverWaveCommunicatorState()
            break
        default:
            break
        }
    }
    
    func recoverWaveCommunicatorState() {
        Task {
            do {
                try await RootAppState.shared.waveCommunicator.recoverState()
            } catch {
                print("Failed to recover wave communicator state: \(error)")
            }
        }
    }
}

