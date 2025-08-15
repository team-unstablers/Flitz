//
//  FlitzWaveService.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import Foundation

import CoreBluetooth

struct FlitzWaveServiceID: RawRepresentable {
    var rawValue: CBUUID
    
    init(rawValue: CBUUID) {
        self.rawValue = rawValue
    }
    
    static let v1Production = FlitzWaveServiceID(rawValue: CBUUID(string: "23976C63-731D-4915-B43B-59CF99DB1AE0"))
#if DEBUG
    static let v1Development = FlitzWaveServiceID(rawValue: CBUUID(string: "5CF49269-42A1-4645-85B3-B46A7A6D650F"))
#endif
    
#if DEBUG
    static let `default` = Self.v1Development
#else
    static let `default` = Self.v1Production
#endif
}


