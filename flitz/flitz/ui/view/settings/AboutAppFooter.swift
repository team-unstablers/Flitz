//
//  AboutAppHeader.swift
//  reazure
//
//  Created by Gyuhwan Park on 11/16/24.
//

import SwiftUI


fileprivate struct AboutAppFooterBackground: View {
    static let backgroundGradient: Gradient = Gradient(colors: [
        Color(hex: 0xF2EC2A),
        Color(hex: 0xFF9500)
    ])

    var body: some View {
        LinearGradient(gradient: Self.backgroundGradient, startPoint: .top, endPoint: .bottom)
    }
}


struct AboutAppFooter: View {
    var body: some View {
        VStack(alignment: .leading) {
            (Text(Image(systemName: "exclamationmark.triangle.fill")) + Text(" ") + Text("알림"))
                .font(.heading3)
                .bold()
                .foregroundStyle(.black.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)
            
            Group {
                Text("**아웃팅**은 심각한 **범죄 행위**입니다. 다른 사람들의 프라이버시를 존중해 주세요.")
                Text("리버스 엔지니어링, 패킷 덤프 등을 통하여 이 소프트웨어 및 통신 내용을 분석하거나 변조하는 행위는 법률에 의해 엄격히 금지되어 있습니다.")
            }
                .font(.small)
                .foregroundStyle(.black.opacity(0.8))

            Group {
                Text("Flitz의 일부 컴포넌트는 자유 소프트웨어의 도움을 받아 개발되었습니다.")
                Text("Flitz에서 사용된 자유 소프트웨어와 각 라이선스는 [오픈 소스 라이선스 페이지](https://docs.flitz.cards/legal/oss.html)에서 확인할 수 있습니다.")
            }
                .font(.small)
                .foregroundStyle(.black.opacity(0.8))
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.Grayscale.gray0.opacity(0.6))
    }
}

#Preview {
    AboutAppFooter()
}
