//
//  User.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/29/24.
//

import Foundation

struct FZCredentials: Codable {
    var username: String
    var password: String
    
    var device_info: String
    var apns_token: String?
}

struct FZUserToken: Codable {
    var token: String
}

struct FZUser: Codable, Identifiable {
    var id: String
    var username: String
    var display_name: String
    
    var title: String
    var bio: String
    var hashtags: [String]
    
    var profile_image_url: String?
    
#if DEBUG
    static let mock0 = FZUser(id: "test0",
                              username: "cheesekun2",
                              display_name: "cheesekun2",
                              
                              title: "Flitz 개발자",
                              bio: "안녕하세요! Flitz 개발자입니다.",
                              hashtags: ["Flitz", "SwiftUI"],
                              
                              profile_image_url: "https://avatars.githubusercontent.com/u/964412?v=4")
 
    
    static let mock1 = FZUser(id: "test",
                              username: "cheesekun",
                              display_name: "cheesekun",
                              
                              title: "Flitz 개발자",
                              bio: "안녕하세요! Flitz 개발자입니다.",
                              hashtags: ["Flitz", "SwiftUI"],
                              
                              profile_image_url: "https://avatars.githubusercontent.com/u/964412?v=4")
                              
#endif
}

struct FZSelfUser: Codable, Identifiable {
    var id: String
    
    var username: String
    var display_name: String
    
    var email: String?
    
    var title: String
    var bio: String
    var hashtags: [String]
    
    var birth_date: String?

    var phone_number: String?
    var profile_image_url: String?
    
    var free_coins: Int
    var paid_coins: Int
    
#if DEBUG
    static let mock1 = FZSelfUser(id: "test",
                                  username: "cheesekun",
                                  display_name: "cheesekun",
                                  
                                  title: "Flitz 개발자",
                                  bio: "안녕하세요! Flitz 개발자입니다.",
                                  hashtags: ["Flitz", "SwiftUI"],
                                  
                                  birth_date: "1999-01-01",
                                  phone_number: "010-1234-1234",
                                  profile_image_url: "https://avatars.githubusercontent.com/u/964412?v=4",
                                  
                                  free_coins: 0,
                                  paid_coins: 0)
#endif
}

struct FZUserIdentity: Codable {
    var gender: Int
    var is_trans: Bool
    var display_trans_to_others: Bool
    var preferred_genders: Int
    var welcomes_trans: Bool
    var trans_prefers_safe_match: Bool
    
#if DEBUG
    static let mock1 = FZUserIdentity(gender: 1,
                                      is_trans: false,
                                      display_trans_to_others: false,
                                      preferred_genders: 1 | 2 | 4,
                                      welcomes_trans: true,
                                      trans_prefers_safe_match: false)
#endif
}

struct FZUserWaveSafetyZone: Codable {
    var latitude: Double?
    var longitude: Double?
    
    var radius: Double // in meters
    
    var is_enabled: Bool
    var enable_wave_after_exit: Bool
    
#if DEBUG
    static let mock1 = FZUserWaveSafetyZone(latitude: 37.5665,
                                            longitude: 126.978,
                                            radius: 1000, // 1km
                                            is_enabled: true,
                                            enable_wave_after_exit: true)
#endif
}
