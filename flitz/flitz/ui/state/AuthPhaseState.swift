//
//  RootAppState.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import Foundation
import SwiftUI
import Combine

class AuthPhaseState: ObservableObject {
    @Published
    var navState: [AuthNavigationItem] = []
   
    init() {
    }
}
