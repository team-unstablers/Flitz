//
//  Notice.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/17/25.
//

import Foundation

struct SimpleNotice: Codable, Identifiable {
    let id: String
    let title: String
    
    let created_at: String
}

struct Notice: Codable {
    let id: String
    let title: String
    let content: String
    
    let created_at: String
}
