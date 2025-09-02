//
//  Notice.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/17/25.
//

import Foundation

struct SupportTicketArgs: Codable {
    let title: String
    let content: String
}

struct SupportTicketResponseArgs: Codable {
    let content: String
}
