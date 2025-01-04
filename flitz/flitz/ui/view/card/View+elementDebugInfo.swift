//
//  View+aspectScale.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import SwiftUI

extension View {
    func elementDebugInfo<Element>(of element: Element) -> some View where Element: Flitz.Element & ObservableObject {
        return self.modifier(ElementDebugIndicator(transform: element.transform))
    }
}

struct ElementDebugIndicator: ViewModifier {
    
    @ObservedObject
    var transform: Flitz.Transform
    
    func body(content: Content) -> some View {
        content
            .border(.blue)
            .overlay {
                GeometryReader { geom in
                    Text("x: \(transform.position.x.format(f: 2)) y: \(transform.position.y.format(f: 2))")
                        .font(.caption)
                        .foregroundStyle(.blue)
                        .fixedSize()
                        .position(x: geom.size.width / 2, y: geom.size.height + 8)
                }
            }
            .overlay {
                GeometryReader { geom in
                    Text("rot: \(transform.rotation.format(f: 2)) scl: \(transform.scale.format(f: 2))")
                        .font(.caption)
                        .foregroundStyle(.blue)
                        .fixedSize()
                        .position(x: geom.size.width / 2, y: -8)
                }
            }

    }
}

fileprivate extension Double {
    func format(f: Int) -> String {
        return String(format: "%.\(f)f", self)
    }
}

fileprivate extension CGFloat {
    func format(f: Int) -> String {
        return String(format: "%.\(f)f", self)
    }
}

#Preview {
    let element = Flitz.Text("Hello, World!")
    
    Text("Hello, World!")
        .elementDebugInfo(of: element)
}
