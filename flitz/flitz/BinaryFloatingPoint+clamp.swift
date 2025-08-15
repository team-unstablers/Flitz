//
//  BinaryFloatingPoint+clamp.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/15/25.
//

extension BinaryFloatingPoint {
    /// inRange 에서의 상대 위치를 outRange 로 선형 매핑.
    /// self 가 inRange 를 벗어나면 outRange 로 클램프됨.
    /// inRange 길이가 0이면 outRange.lowerBound 반환.
    func clamp(inRange: ClosedRange<Self>, outRange: ClosedRange<Self>) -> Self {
        precondition(inRange.lowerBound <= inRange.upperBound, "inRange must be valid")
        precondition(outRange.lowerBound <= outRange.upperBound, "outRange must be valid")

        let inSpan = inRange.upperBound - inRange.lowerBound
        if inSpan == 0 { return outRange.lowerBound }

        // 0~1 로 정규화
        let t = (self - inRange.lowerBound) / inSpan
        let tClamped = max(Self(0), min(Self(1), t))

        // outRange 로 매핑
        return outRange.lowerBound + (outRange.upperBound - outRange.lowerBound) * tClamped
    }
}
