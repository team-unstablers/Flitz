//
//  Paginated.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/29/24.
//

struct Paginated<T: Codable>: Codable {
    var next: String?
    var previous: String?
    var results: [T]
}
