//
//  FZFormError.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/15/25.
//

enum FZFormError {
    case required
    case tooLong(maxLength: Int)
    
    var message: String {
        switch self {
        case .required:
            return "필수로 입력해야 합니다"
        case .tooLong(let maxLength):
            return "최대 \(maxLength)자까지 입력할 수 있습니다"
        }
    }
}
