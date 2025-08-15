//
//  String+paddedBase64String.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/15/25.
//

extension String {
    var paddedBase64String: Self {
        let offset = count % 4
        guard offset != 0 else { return self }
        return padding(toLength: count + 4 - offset, withPad: "=", startingAt: 0)
    }
}
