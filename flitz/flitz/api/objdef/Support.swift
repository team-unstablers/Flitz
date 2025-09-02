//
//  Notice.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/17/25.
//

import Foundation

struct SupportTicket: Codable, Identifiable {
    let id: String
    let title: String
    let content: String
    let is_resolved: Bool
    let created_at: String

#if DEBUG
    static let mocked1 = SupportTicket(
        id: "1",
        title: "앱 실행 시 바로 종료되는 문제",
        content: """
앱을 실행하면 로고 화면이 잠깐 보이다가 바로 종료됩니다. 
아이폰을 재부팅하고 캐시도 지워봤고, 앱도 두 번 다시 설치해봤는데 증상이 그대로예요. 
제가 쓰는 기기는 iPhone 13 Pro이고, iOS 17.5.1 버전입니다. 
어제 업데이트하기 전에는 잘 됐는데, 업데이트 이후부터 이런 문제가 생겼습니다.
""",
        is_resolved: false,
        created_at: "2024-06-01T10:00:00.000Z"
    )
#endif
}

struct SupportTicketResponse: Codable {
    let responder: String
    let content: String
    let created_at: String

#if DEBUG
    static let mocked1 = SupportTicketResponse(
        responder: "병아리",
        content: """
앱 실행이 안 돼서 불편을 겪으셨다니 정말 죄송합니다. 
말씀해주신 증상은 최근 업데이트 과정에서 호환성 문제가 생긴 경우일 수 있습니다. 
번거로우시겠지만, 앱을 완전히 삭제하신 뒤 기기를 재부팅하고 
다시 앱스토어에서 설치해 보실 수 있을까요? 
혹시 종료 직전에 에러 메시지가 잠깐이라도 뜨는지 확인해주시면 문제를 파악하는 데 큰 도움이 됩니다.
""",
        created_at: "2024-06-01T12:00:00.000Z"
    )

    static let mocked2 = SupportTicketResponse(
        responder: "__USER__",
        content: """
빠르게 답변해주셔서 감사합니다! 알려주신 대로 앱을 삭제하고 
아이폰을 껐다 켠 다음 다시 설치했더니 이번에는 정상적으로 실행이 됩니다. 
로그인도 잘 되고 주요 기능도 문제없이 쓸 수 있네요. 
빠른 대응 덕분에 금방 해결할 수 있었습니다.
""",
        created_at: "2024-06-01T13:00:00.000Z"
    )

    static let mocked3 = SupportTicketResponse(
        responder: "병아리",
        content: """
정상적으로 실행된다고 하니 정말 다행이에요! 
간혹 업데이트 후에 캐시 문제 때문에 비슷한 증상이 나타나기도 해서, 
말씀드린 방법으로 재설치하면 해결되는 경우가 많습니다. 
혹시 앞으로도 다른 문제가 생기거나, 개선했으면 하는 부분이 있으면 
언제든 편하게 알려주세요. 보내주시는 피드백은 더 나은 서비스를 만드는 데 큰 힘이 됩니다.
""",
        created_at: "2024-06-01T14:00:00.000Z"
    )
#endif
}
