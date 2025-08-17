//
//  SafetyResources+Korean.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/10/25.
//

import Foundation

extension SafetyResources {
    struct Korean {
        static let chingusai = SafetyResource(name: "친구사이 \"마음연결\" 전화상담",
                                              description: "친구사이에서 운영하는 성소수자 자살예방 상담 전화 안내 페이지입니다.",
                                              url: URL(string: "https://chingusai.net/xe/quick")!)
        
        static let lsangdam = SafetyResource(name: "한국레즈비언상담소",
                                             description: "한국레즈비언상담소의 상담 안내 페이지입니다.",
                                             url: URL(string: "https://lsangdam.org/info/")!)
        
        static let transgenderOrKr = SafetyResource(name: "트랜스젠더 인권단체 조각보",
                                             description: "트랜스젠더 인권단체 조각보의 홈페이지입니다.",
                                             url: URL(string: "https://transgender.or.kr/index")!)
        
        static let ddingdong = SafetyResource(name: "띵동 위기상담",
                                              description: "청소년 성소수자를 위한 위기 상담 서비스입니다.",
                                              url: URL(string: "https://ddingdong.kr/counsel")!,
                                              
                                              // TODO: 알림 누르면 계정 삭제 페이지로 이동하도록 유도한다
                                              importantNote: .init(title: "중요한 알림 — 여러분의 안전이 가장 중요해요",
                                                                   subtitle: "안전을 위해 앱 이용을 당장 중단하고, 도움을 받는 것을 권장해요.",
                                                                   message: "Flitz는 성인들을 위한 공간이기 때문에, 청소년 여러분들이 이 앱을 이용하면 위험한 상황에 처할 수 있어요."))
        
        static let flitzMinorSafety = SafetyResource(name: "왜 Flitz는 청소년이 사용할 수 없나요?",
                                                     description: "만약 당신이 청소년이라면, Flitz 이용을 중단해주세요.",
                                                     url: FlitzDocs.ko.extras.minorSafety.url)
        
        static let allCases: [SafetyResource] = [
            chingusai,
            lsangdam,
            transgenderOrKr,
            ddingdong,
            flitzMinorSafety
        ]
    }
}
