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
            return NSLocalizedString("아직 교환된 카드가 없어요", comment: "NoCardsAvailableReason::title")
        
        case .insufficientPermission:
            return NSLocalizedString("추가 권한이 필요해요", comment: "NoCardsAvailableReason::title")
        }
    }
    
    var description: String {
        switch self {
        case .noCardsExchanged:
            return NSLocalizedString("다른 Flitz 사용자와 마주치게 되면 카드가 교환될 거예요!", comment: "NoCardsAvailableReason::description")
            
        case .insufficientPermission:
            return NSLocalizedString("Flitz가 다른 사용자와 카드를 교환할 수 있도록 Bluetooth 및 위치 정보 권한을 허용해 주세요.", comment: "NoCardsAvailableReason::description")
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
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
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
