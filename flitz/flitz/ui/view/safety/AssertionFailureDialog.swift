//
//  AssertionFailureDialog.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/9/25.
//

import SwiftUI
import SwiftUIX

enum AssertionFailureReason {
    case sslFailure
    case other(reason: String)
    
    var description: String {
        switch self {
        case .sslFailure:
            return NSLocalizedString("ui.safety.assertion.ssl_failure_description", comment: "안전한 연결을 수립할 수 없었어요.\n\n이 문제는 보호되지 않은 공공 Wi-Fi나 일부 회사/학교 네트워크에서 발생할 수 있으니, 다른 네트워크 환경에서 다시 시도해 주세요.")
        case .other(let reason):
            return reason
        }
    }
    
    var asDisplayText: String {
        switch self {
        case .sslFailure:
            return "SSL_FAILURE"
        case .other(_):
            return "OTHER"
        }
    }
    
    var asLocalizedDisplayText: String {
        switch self {
        case .sslFailure:
            return NSLocalizedString("ui.safety.assertion.server_identity_unclear", comment: "서버의 신원이 불분명합니다")
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
                Text(NSLocalizedString("ui.safety.assertion.app_suspended", comment: "앱이 잠시 중단되었습니다"))
                    .font(.fzHeading2)
                    .bold()
                
                Group {
                    Text(NSLocalizedString("ui.safety.assertion.safety_suspension_message", comment: "Flitz에서 사용자님의 안전을 위해 앱을 잠시 중단했어요.").byCharWrapping)
                    Text(reason.description.byCharWrapping)
                }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.fzMain)
                
                FZButton(size: .large) {
                    Flitz.exitGracefully()
                } label: {
                    Text(NSLocalizedString("ui.safety.assertion.exit_app", comment: "앱 종료하기"))
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
        AssertionFailureDialog(reason: .sslFailure)
    }
}
