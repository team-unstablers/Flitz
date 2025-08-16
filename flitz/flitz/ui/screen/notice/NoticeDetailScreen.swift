//
//  NoticeListScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/17/25.
//

import SwiftUI

struct NoticeDetailHeader: View {
    let title: String
    let createdAt: Date
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title.byCharWrapping)
                    .font(.fzHeading3)
                    .foregroundStyle(Color.Brand.black0)
                    .semibold()
                    .lineLimit(1)
                
                Text(createdAt.localeDateString)
                    .font(.fzMain)
                    .foregroundStyle(Color.Grayscale.gray6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            
            Divider()
                .background(Color.Grayscale.gray2)
        }
    }
}

struct NoticeDetailScreen: View {
    @EnvironmentObject
    var appState: RootAppState
    
    let noticeId: String
    
    var dummyContent: AttributedString {
        let content =
"""
**새하얀 눈**에 감싸여 아직 조용히 잠든 생명은
**봄의 온기**를 바라며 언젠가 깨어나겠지
살며시, 살며시 새로운 계절이
너의 기적을 기다리고 있어, 바로 곁에서 기다리고 있어

겨울 하늘에 희미하게 울려 퍼지는 축제의 음악 소리
차가워진 그 손을 꼭 잡으니, 등불이 참 아름답네
아름다운 세상은 너무나 눈부셔서 아득히 번져가고
~~덧없는 나날~~들에 안녕을 고하고, **신비로운 세상으로 돌아가자**

사람이 내뿜는 반짝임에는 [미래가 있어](https://google.com) 
**(⚠️ 외부 링크로 이동합니다)**
꺼져버린 등불을 세어보며 둘이서 돌아가자

꽃이여, 어둠이여, 움트고 피어나라
드높이, 드높이 노래하며 피어나라
신이여, 바람이여, 영원토록
너의 꿈은 화창하게 빛나리

- 테스트
- 테스트 2
- 테스트 3

## 헤더는 동작하지 않는다.

`$ cd /usr/src/flitz`
`$ make flitz -j8 --with-love`

```
multiple line code block
역시 동작하지 않는다.
안타깝군!
```
"""
        
        return try! AttributedString(markdown: content, options: AttributedString.MarkdownParsingOptions(
            allowsExtendedAttributes: true,
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                NoticeDetailHeader(title: "테스트 공지사항", createdAt: Date())
                ScrollView {
                    Text(dummyContent)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.main)
                        .foregroundStyle(Color.Brand.black0)
                }
            }
        }
        .navigationTitle("공지사항")
    }
}

#Preview {
    NoticeDetailScreen(noticeId: "test")
        .environmentObject(RootAppState())
}
