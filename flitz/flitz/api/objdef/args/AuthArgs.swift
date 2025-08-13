//
//  AuthArgs.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/14/25.
//

import Foundation

struct UserRegistrationArgs: Codable {
    var username: String
    var password: String
    
    var display_name: String
    
    var title: String
    var bio: String
    var hashtags: [String]
}
