//
//  AppDelegate.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/15/24.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    private let logger = createFZOSLogger("AppDelegate")
    
    static fileprivate(set) var apnsToken: String? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
        
        UserDefaults.standard.register(defaults: [
            "FlitzWaveEnabled": true,
        ])
        
        UNUserNotificationCenter.current().delegate = self
        
        UIFont.setupUINavigationBarTypography()
        
#if DEBUG
        FZ_GLOBAL_LOGGER_LEVEL = .verbose
#else
        FZ_GLOBAL_LOGGER_LEVEL = .normal
#endif
        
        recoverWaveCommunicatorState()
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let stringifiedToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Self.apnsToken = stringifiedToken
        
        logger.debug("got APNS Token: \(stringifiedToken)")
        
        RootAppState.shared.updateAPNSToken()
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        defer { completionHandler(.newData) }
        
        guard let type = userInfo["type"] as? String else {
            return
        }
        
        switch type {
        case "wake_up":
            recoverWaveCommunicatorState()
            WaveLocationReporter.shared.requestLocation()
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
                logger.debug("Failed to recover wave communicator state: \(error)")
            }
        }
    }
}

