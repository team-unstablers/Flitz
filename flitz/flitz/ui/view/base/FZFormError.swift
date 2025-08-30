//
//  FZFormError.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/15/25.
//

enum FZFormError {
    case required
    case tooLong(maxLength: Int)
    case tooShort(minLength: Int)
    
    case notAcceptable
    case alreadyTaken
    
    case passwordNotStrongEnough
    case passwordNotEqual
    
    // ??? 왜 이런거 만들어요
    case checkInProgress
    
    var message: String {
        switch self {
        case .required:
            return "필수로 입력해야 합니다"
        case .tooLong(let maxLength):
            return "최대 \(maxLength)자까지 입력할 수 있습니다"
        case .tooShort(let minLength):
            return "최소 \(minLength)자 이상 입력해야 합니다"
        
        case .notAcceptable:
            return "이 값은 사용할 수 없습니다"
        case .alreadyTaken:
            return "입력된 유저네임은 이미 사용 중입니다"
            
        case .passwordNotStrongEnough:
            return "이 비밀번호는 너무 약하기 때문에 사용할 수 없습니다"
        case .passwordNotEqual:
            return "비밀번호가 일치하지 않습니다"
            
        case .checkInProgress:
            return "확인 중..."
        }
    }
}
