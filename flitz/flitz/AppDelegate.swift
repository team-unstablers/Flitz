//
//  AppDelegate.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/15/24.
//

import Foundation
import Sentry

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    private let logger = createFZOSLogger("AppDelegate")
    
    static fileprivate(set) var apnsToken: String? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        #if DEBUG
        logger.info("debug build, sentry disabled")
        #else
        SentrySDK.start { options in
            options.dsn = "https://0db30a3cf6f155e784a36ee4a3deed90@o576637.ingest.us.sentry.io/4509936951296000"
            options.debug = false // Enabled debug when first installing is always helpful

            // Adds IP for users.
            // For more information, visit: https://docs.sentry.io/platforms/apple/data-management/data-collected/
            options.sendDefaultPii = true

            // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
            // We recommend adjusting this value in production.
            options.tracesSampleRate = 0.2

            // Configure profiling. Visit https://docs.sentry.io/platforms/apple/profiling/ to learn more.
            options.configureProfiling = {
                $0.sessionSampleRate = 0.1 // We recommend adjusting this value in production.
                $0.lifecycle = .trace
            }

            // Uncomment the following lines to add more data to your events
            // options.attachScreenshot = true // This adds a screenshot to the error events
            // options.attachViewHierarchy = true // This adds the view hierarchy to the error events
            
            // Enable experimental logging features
            options.experimental.enableLogs = true
        }
        #endif

        application.registerForRemoteNotifications()
        
        UserDefaults.standard.register(defaults: [
            "FirstRun": true,
            "FlitzWaveEnabled": true,
        ])
        
        // IMPORTANT: remove keychain-based context on first run
        if UserDefaults.standard.bool(forKey: "FirstRun") {
            FZAPIContext.delete()
            RootAppState.shared.reloadContext()
            
            UserDefaults.standard.set(false, forKey: "FirstRun")
        }
        
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
            // WaveLocationReporter.shared.requestLocation()
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
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url)
        print(options)
        
        return true
    }
}

