//
//  AppDelegate.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/15/24.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UIFont.setupUINavigationBarTypography()
        
        return true
    }
    
    
}
