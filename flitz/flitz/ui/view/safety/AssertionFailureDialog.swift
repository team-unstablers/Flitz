//
//  AssertionFailureDialog.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/9/25.
//

import SwiftUI
import SwiftUIX

enum AssertionFailureReason {
    case mitmDetected
    case other(reason: String)
    
    var description: String {
        switch self {
        case .mitmDetected:
            return "통신 환경이 안전하지 않습니다. 누군가가 통신 내용을 훔쳐보려고 하고 있을 수도 있습니다.\n\n- 비밀번호가 걸려 있지 않은 공공 Wi-Fi를 사용하면 위험에 노출될 수 있습니다.\n- 회사나 학교 네트워크에서는 앱이 정상적으로 작동하지 않을 수 있습니다."
        case .other(let reason):
            return reason
        }
    }
    
    var asDisplayText: String {
        switch self {
        case .mitmDetected:
            return "MITM_DETECTED"
        case .other(_):
            return "OTHER"
        }
    }
    
    var asLocalizedDisplayText: String {
        switch self {
        case .mitmDetected:
            return "인증서 고정 또는 mTLS 협상에 실패했습니다"
        case .other(let reason):
            return reason
        }
    }
}

struct AssertionFailureDialogBackdrop: View {
    var body: some View {
        BlurEffectView(style: .systemThinMaterialDark)
            .edgesIgnoringSafeArea(.all)
    }
}

struct AssertionFailureDialogBody: View {
    var reason: AssertionFailureReason
    
    var body: some View {
        VStack {
            VStack(spacing: 16) {
                Text("앱이 일시 중단되었습니다")
                    .font(.fzHeading2)
                    .bold()
                
                Group {
                    Text("Flitz에서 사용자님의 안전을 위해 앱을 중단하였습니다.".byCharWrapping)
                    Text(reason.description.byCharWrapping)
                    Text("안전이 확보되었다고 생각되면 앱을 다시 시작해 주세요.".byCharWrapping)
                }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.fzMain)
                
                FZButton(size: .large) {
                    Flitz.exitGracefully()
                } label: {
                    Text("Flitz 종료하기")
                        .font(.fzHeading3)
                        .semibold()
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .compositingGroup()
            .shadow(radius: 16)
        }
        .padding(24)
    }
}

struct AssertionFailureDialog: View {
    let reason: AssertionFailureReason
    
    var body: some View {
        ZStack {
            AssertionFailureDialogBackdrop()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack {
                AssertionFailureDialogBody(reason: reason)
                Text("FATAL ERROR (reason=\(reason.asDisplayText))\n\(reason.asLocalizedDisplayText)")
                    .multilineTextAlignment(.center)
                    .opacity(0.5)
                    .font(.system(size: 12))
                    .monospaced()
                    .foregroundStyle(.white)
                    .shadow(radius: 8)
            }
        }
    }
}

#Preview {
    ZStack {
        Text("test\ntest\ntest\ntest\ntest\ntest\ntest\ntest")
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
        AssertionFailureDialog(reason: .mitmDetected)
    }
}
