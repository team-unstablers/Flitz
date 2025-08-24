//
//  Flitz+Meta.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/10/25.
//

import Foundation

extension Flitz {
    static let codename = "prelude"
    
    static var version: String {
        let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        
        return bundleVersion ?? "unknown"
    }
    
    static var build: String {
        let buildVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        
        return buildVersion ?? "unknown"
    }
}
