//
//  NicePhoneVerification.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/29/25.
//

import SwiftUI
import WebKit
import Combine
import SafariServices



struct NicePhoneVerificationWebView: UIViewRepresentable {
    @Binding
    var html: String
    var handler: (RegistrationCompletePhoneVerificationArgs?) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.htmlContent != html {
            webView.stopLoading()

            webView.loadHTMLString(html, baseURL: URL(string: "https://challenges.app.flitz.cards")!)
            context.coordinator.htmlContent = html
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(handler: self.handler)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var htmlContent: String = ""
        
        var handler: (RegistrationCompletePhoneVerificationArgs?) -> Void
        
        init(handler: @escaping (RegistrationCompletePhoneVerificationArgs?) -> Void) {
            self.handler = handler
        }
        
        // WKNavigationDelegate - 외부 링크 처리
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            defer {
                decisionHandler(.allow)
            }
            
            if let url = navigationAction.request.url {
                if url.scheme == "flitz" && url.host() == "register" && url.path() == "/phone-verification/kr/callback",
                   let query = url.query(percentEncoded: false)
                {
                    var queryDict: [String: String] = [:]
                    let components = query.split(separator: "&")
                    for component in components {
                        guard let separatorIndex = component.firstIndex(of: "=") else {
                            continue
                        }
                        let key = String(component[..<separatorIndex])
                        let value = String(component[component.index(after: separatorIndex)...])
                        
                        queryDict[key] = value
                    }
                    
                    print(queryDict)
                    
                    guard let payload = queryDict["enc_data"],
                          let hmac = queryDict["integrity_value"] else {
                        handler(nil)
                        return
                    }
                    
                    let args = RegistrationCompletePhoneVerificationArgs(
                        verification_code: nil,
                        
                        encrypted_payload: payload,
                        payload_hmac: hmac
                    )
                    
                    handler(args)
                }
            }
        }
        
        // WKUIDelegate - 새 창 처리
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = navigationAction.request.url {
                print(url)
                UIApplication.shared.open(url)
            }
            return nil
        }
    }
}


struct NicePhoneVerification: View {
    let payload: String
    let hmac: String
    
    let tokenVersionId: String
    
    var handler: (RegistrationCompletePhoneVerificationArgs?) -> Void
    
    
    @State
    var html: String = ""
    
    func generateHTML() -> String {
"""
<!DOCTYPE html>
<html>
<head>
<script>
window.onload = () => {
    form.action = "https://nice.checkplus.co.kr/CheckPlusSafeModel/service.cb";
    form.method = "post";
    form.submit();
}
</script>
</head>
<body>
<form name="form" id="form">
      <input type="hidden" id="m" name="m" value="service" />
      <input type="hidden" id="token_version_id" name="token_version_id" value="\(tokenVersionId)" />
      <input type="hidden" id="enc_data" name="enc_data" value="\(payload)" />
      <input type="hidden" id="integrity_value" name="integrity_value" value="\(hmac)" />
</form>
</body>
</html>
"""
    }
    
    var body: some View {
        NicePhoneVerificationWebView(html: $html) { args in
            handler(args)
        }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                self.html = generateHTML()
            }
    }
}


#Preview {
    VStack {
        NicePhoneVerification(
            payload: "75c4BGds6dPdWRwV4fb5Cy8oayJw5gwDFO5/wgLB8v/M537gajNUzzfzwaLwoHEktYRrK9/NIVP10Ahu2eX1N9f41pRMC8t5lMPNpg40hceT7rztcQT1Z1nG2t/lVlHGaVEbA2KTYiJ5XpR9fmIIYEkfIrL8jZN0ttf1GLRjuaWTYT6RK60aqHxjWXpUfy4YfHMQOi54VU1fMkfkguv9vXiXDdKjkdYfkXHjhN/dApZbsuvB4YcqDHgpWDhjqa8KraD+CYK8scnlD7JC0n7Ak+y4d8lUgDKUAJOQG0XjKfs=",
            hmac: "Dn80YzRJKfYuzyZM9ZF4HMDjxRE777S3HFa47FJ45pc=",
            tokenVersionId: "2025082920492322-NC41CG970-ADF12-2GCAB42C7F",
        ) { value in
            print(value)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}

