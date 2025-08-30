//
//  SignInScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

#if DEBUG
struct ServerSelector: View {
    
    @Binding
    var host: FZAPIServerHost
    
    var body: some View {
        VStack {
            Picker("host", selection: $host) {
                ForEach(FZAPIServerHost.allCases, id: \.self) { host in
                    Text(host.description)
                }
            }
            Text("호스트: \(host.rawValue)")
        }
    }
    
}
#endif

struct SignInScreen: View {
    typealias AuthHandler = (FZAPIContext) -> Void
    
    @EnvironmentObject
    var authPhaseState: AuthPhaseState
    
#if DEBUG
    @State
    private var host: FZAPIServerHost = .default
#endif
    
    @State
    private var busy = false
    
    @State
    private var username = ""
    
    @State
    private var password = ""
    
    @State
    private var turnstileToken = ""
    
    @State
    private var turnstileNonce = UUID()
    
    var authHandler: AuthHandler
    
    var body: some View {
        VStack(spacing: 0) {
            Text("로그인")
                .font(.fzHeading1)
                .bold()
                .padding(.bottom, 40)
            
            FZEntry("유저네임") {
                TextField("유저네임을 입력해주세요", text: $username)
                    .autocorrectionDisabled(true)
                    .background(.clear)
            }
            .padding(.bottom, 20)
            .disabled(busy)

            FZEntry("비밀번호") {
                SecureField("비밀번호를 입력해주세요", text: $password)
                    .autocorrectionDisabled(true)
                    .background(.clear)
            }
            .padding(.bottom, 24)
            .disabled(busy)
            
            CFTurnstile(action: "request_token", nonce: turnstileNonce) { token in
                print(token)
                self.turnstileToken = token
            }
            
            FZButton(size: .large) {
                self.performSignIn()
            } label: {
                if busy {
                    ProgressView()
                } else {
                    Text("로그인")
                        .font(.fzMain)
                        .semibold()
                }
            }
            .padding(.vertical, 24)
            .disabled(username.isEmpty || password.isEmpty || turnstileToken.isEmpty || busy)
            
            HStack(spacing: 0) {
                FZButton(palette: .clear, size: .textual) {
                    authPhaseState.navState = [.signUp]
                } label: {
                    Text("회원가입")
                        .font(.fzMain)
                }
                
                Rectangle()
                    .fill(Color.Grayscale.gray3)
                    .frame(width: 1, height: 14)
                    .padding(.horizontal, 12)
                
                FZButton(palette: .clear, size: .textual) {
                    authPhaseState.navState.append(.findPassword)
                } label: {
                    Text("비밀번호 찾기")
                        .font(.fzMain)
                }
            }
            .padding(.vertical, 24)
            
#if DEBUG
            VStack(spacing: 0) {
                Text("디버그 모드의 클라이언트입니다")
                    .padding(.bottom, 16)
                    .bold()
                    .foregroundStyle(.red.opacity(0.8))
                Group {
                    if host == .production {
                        Text("**경고**: 특별한 사유가 있지 않은 이상 이 클라이언트로 프로덕션 서버에 접속하는 행위는 삼가하십시오.")
                    } else {
                        Text("**경고**: 테스트 서버이므로 자주 사용하는 비밀번호를 사용하지 마십시오.")
                    }
                }
            }
            .font(.fzMain)
#endif
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func performSignIn() {
        busy = true
        
        var context = FZAPIContext()
#if DEBUG
        context.host = host
#endif
        
        let client = FZAPIClient(context: context)
        let credentials = FZCredentials(username: self.username,
                                        password: self.password,
                                        device_info: FZAPIClient.userAgent,
                                        apns_token: AppDelegate.apnsToken,
                                        turnstile_token: self.turnstileToken)
        
        Task {
            defer { busy = false }
            do {
                let token = try await client.authorize(with: credentials)
                var newContext = context
                newContext.token = token.token
                newContext.refreshToken = token.refresh_token
                
                // FIXME: assert() 쓰지 마세요!!!
                assert(newContext.valid())
                
                DispatchQueue.main.async {
                    self.authHandler(newContext)
                }
            } catch {
                print(error)
                
                // reset turnstile
                self.turnstileToken = ""
                self.turnstileNonce = UUID()
            }
        }
    }
}

#Preview {
    SignInScreen { _ in
    }
}
