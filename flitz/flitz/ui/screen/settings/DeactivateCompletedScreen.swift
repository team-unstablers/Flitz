//
//  ConfirmDeactivateScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/22/25.
//

import SwiftUI

struct DeactivateCompletedScreen: View {
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("이용해 주셔서 감사합니다".byCharWrapping)
                            .font(.fzHeading1)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("계정 삭제가 완료되었습니다.\n그동안 Flitz를 이용해 주셔서 감사합니다.".byCharWrapping)
                            .font(.fzMain)
                            .foregroundStyle(Color.Grayscale.gray6)
                        
                        /*
                        HStack(alignment: .top) {
                            Image("NoteIcon")
                                .padding(.top, 3)
                            Text("내부 시스템에 의해 다른 사용자를 괴롭히거나 Flitz 정책을 위반한 사실이 확인될 경우, 데이터 삭제가 최대 7일까지 보류될 수 있습니다.".byCharWrapping)
                                .font(.fzMain)
                                .foregroundStyle(Color.Grayscale.gray6)
                        }
                        .padding(.top, 40)
                         */
                    }
                        .padding(.top, 40)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
            }
            VStack {
                FZButton(size: .large) {
                    Flitz.exitGracefully()
                } label: {
                    Text("Flitz 종료하기")
                        .font(.fzHeading3)
                        .semibold()
                }
            }
            .padding(16)
        }
        .navigationTitle("계정 삭제 완료")
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    DeactivateCompletedScreen()
        .environmentObject(RootAppState())
}
