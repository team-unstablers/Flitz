//
//  NoCardsAvailable.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/31/24.
//

import SwiftUI

enum NoCardsAvailableReason {
    case noCardsExchanged
    case insufficientPermission
    
    var title: String {
        switch self {
        case .noCardsExchanged:
            return NSLocalizedString("오늘은 교환된 카드가 없습니다", comment: "NoCardsAvailableReason::title")
        
        case .insufficientPermission:
            return NSLocalizedString("추가 권한이 필요합니다", comment: "NoCardsAvailableReason::title")
        }
    }
    
    var description: String {
        switch self {
        case .noCardsExchanged:
            return NSLocalizedString("내일은 멋진 카드를 받을 수 있을지도 몰라요.\nFlitz 앱이 열심히 찾아줄 거에요!", comment: "NoCardsAvailableReason::description")
            
        case .insufficientPermission:
            return NSLocalizedString("Flitz 앱이 다른 사람과 카드를 교환할 수 있도록 Bluetooth 및 위치 정보 권한을 허용해 주세요.", comment: "NoCardsAvailableReason::description")
        }
    }
    
    var shouldShowSettingsButton: Bool {
        switch self {
        case .insufficientPermission:
            return true
        default:
            return false
        }
    }
    
}

struct NoCardsAvailable: View {
    var reason: NoCardsAvailableReason
    
    var body: some View {
        DummyCardView()
            .shadow(radius: 8)
            .blur(radius: 8)
            .overlay {
                VStack() {
                    Text(reason.title)
                        .font(.heading2)
                        .bold()
                        .foregroundStyle(Color.Grayscale.gray8)
                    
                    Text(reason.description)
                        .multilineTextAlignment(.center)
                        .font(.main)
                        .foregroundStyle(Color.Grayscale.gray7)
                        .padding(.bottom, 16)
                    
                    if reason.shouldShowSettingsButton {
                        FZButton {
                            
                        } label: {
                            Text("앱 설정 열기")
                        }
                        
                        FZButton {
                            
                        } label: {
                            Text("Wave에 대해 자세히 알아보기")
                        }
                    }
                }
                    .padding()
            }
    }
}


#Preview {
    NoCardsAvailable(reason: .insufficientPermission)
}
