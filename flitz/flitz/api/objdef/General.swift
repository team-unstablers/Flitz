//
//  General.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import Foundation

struct Ditch: Codable {
    // void
}

struct SimpleResponse: Codable {
    let is_success: Bool
    
    /// 오류가 발생한 경우, 그 이유를 설명하는 문자열입니다. (as translation key)
    let reason: String?
    
    /// 추가적인 데이터가 있는 경우, key-value 쌍으로 제공됩니다.
    /// key-value 쌍의 값은 모두 문자열로 제공됩니다.
    let additional_data: [String: String]?
    /// 성공했지만 추가적인 메시지가 있는 경우, 그 메시지가 제공됩니다. (as translation key)
    let additional_message: String?
}
