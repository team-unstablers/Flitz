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
        Picker("host", selection: $host) {
            ForEach(FZAPIServerHost.allCases, id: \.self) { host in
                Text(host.description)
            }
        }
        Text("호스트: \(host.rawValue)")
    }
    
}
#endif

struct SignInScreen: View {
    typealias AuthHandler = (FZAPIContext) -> Void
    
#if DEBUG
    @State
    private var host: FZAPIServerHost = .default
#endif
    
    @State
    private var username = ""
    
    @State
    private var password = ""
    
    var authHandler: AuthHandler
    
    var body: some View {
        VStack {
#if DEBUG
            ServerSelector(host: $host)
#endif
            
            
            TextField("username", text: $username)
                .autocorrectionDisabled(true)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            SecureField("password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            HStack {
                Button("로그인") {
                    self.performSignIn()
                }
                Button("회원가입") {
                    self.performSignUp()
                }
            }
            .padding(.vertical, 24)
            
           Text("**경고**: 테스트 서버이므로 자주 사용하는 비밀번호를 사용하지 마십시오.")
        }
        .padding()
    }
    
    func performSignIn() {
        var context = FZAPIContext()
#if DEBUG
        context.host = host
#endif
        
        let client = FZAPIClient(context: context)
        let credentials = FZCredentials(username: self.username,
                                        password: self.password,
                                        device_info: "FlitzCardEditorTest.app")
        
        Task {
            do {
                let token = try await client.authorize(with: credentials)
                var newContext = context
                newContext.token = token.token
                
                DispatchQueue.main.async {
                    self.authHandler(newContext)
                }
            } catch {
                print(error)
            }
        }
    }
    
    func performSignUp() {
        var context = FZAPIContext()
#if DEBUG
        context.host = host
#endif
        
        let client = FZAPIClient(context: context)
        let credentials = FZCredentials(username: self.username,
                                        password: self.password,
                                        device_info: "FlitzCardEditorTest.app")
        
        Task {
            do {
                try await client.signup(with: credentials)
                
                DispatchQueue.main.async {
                    self.performSignIn()
                }
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    SignInScreen { _ in
    }
}
