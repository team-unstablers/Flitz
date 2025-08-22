//
//  Flitz.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/10/25.
//

import UIKit

struct Flitz {
    /**
     우아하게 자기 자신을 종료하려고 시도합니다.
     - NOTE: 아무 때나 막 사용하지 마십시오!
     */
    static func exitGracefully() {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }
}
