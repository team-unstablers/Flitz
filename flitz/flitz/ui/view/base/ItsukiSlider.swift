//
//  ItsukiSlider.swift
//  https://levelup.gitconnected.com/swiftui-custom-slider-305aa7cf9e01
//
//  Thank you, Itsuki-san!
//

import SwiftUI

struct ItsukiSlider<S1: ShapeStyle, S2: ShapeStyle, T1: View, T2: View>: View {
    private var fillBackground: S1
    private var fillTrack: S2
    private var firstThumb: T1?
    private var secondThumb: T2?

    private var barStyle: (height: Double?, cornerRadius: Double)
    private var bounds: ClosedRange<Double>
    private var step: Double?
    @Binding private var value: ClosedRange<Double>
    
    var body: some View {

        GeometryReader { geometry in
            let frame = geometry.frame(in: .local)
            RoundedRectangle(cornerRadius: barStyle.cornerRadius)
                .fill(fillBackground)
            
            ThumbView(value: $value, in: bounds, step: step, maxWidth: frame.width, cornerRadius: barStyle.cornerRadius, fill: fillTrack, firstThumb: {
                if let firstThumb = firstThumb { firstThumb }
                else { defaultThumb }
            }, secondThumb: {
                if let secondThumb = secondThumb { secondThumb }
                else { defaultThumb }
            })
        }
        .frame(height: barStyle.height == nil ? nil : barStyle.height!)
    }
    
    private var defaultThumb: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 24, height: 24)
            .shadow(color: .black.opacity(0.3), radius: 3, x: 1, y: 1)
    }

}

extension ItsukiSlider where T1 == Never, T2 == Never, S1 == Color, S2 == Color {
    init<V>(value: Binding<ClosedRange<V>>, in bounds: ClosedRange<V>, step: V.Stride? = nil, barStyle: (height: Double?, cornerRadius: Double) = (nil, 8)) where V : BinaryFloatingPoint, V.Stride : BinaryFloatingPoint {
        let bindingDouble = Binding<ClosedRange<Double>>(
            get: { Double(value.wrappedValue.lowerBound)...Double(value.wrappedValue.upperBound) },
            set: {
                value.wrappedValue = V($0.lowerBound)...V($0.upperBound)
            }
        )
        self._value = bindingDouble
        self.bounds = Double(bounds.lowerBound)...Double(bounds.upperBound)
        self.step = step == nil ? nil : Double.Stride(step!)
        self.barStyle = barStyle
        self.fillBackground = .gray.opacity(0.3)
        self.fillTrack = .blue
    }
}

extension ItsukiSlider  {
    init<V>(value: Binding<ClosedRange<V>>, in bounds: ClosedRange<V>, step: V.Stride? = nil, barStyle: (height: Double?, cornerRadius: Double), fillBackground: S1, fillTrack: S2, @ViewBuilder firstThumb: () -> T1, @ViewBuilder secondThumb: () -> T2 ) where V : BinaryFloatingPoint, V.Stride : BinaryFloatingPoint {
        let bindingDouble = Binding<ClosedRange<Double>>(
            get: { Double(value.wrappedValue.lowerBound)...Double(value.wrappedValue.upperBound) },
            set: {
                value.wrappedValue = V($0.lowerBound)...V($0.upperBound)
            }
        )
        self._value = bindingDouble
        self.bounds = Double(bounds.lowerBound)...Double(bounds.upperBound)
        self.step = step == nil ? nil : Double.Stride(step!)
        self.barStyle = barStyle
        self.fillBackground = fillBackground
        self.fillTrack = fillTrack
        self.firstThumb = firstThumb()
        self.secondThumb = secondThumb()
    }
}

fileprivate struct ThumbView<S: ShapeStyle, T1: View, T2: View>: View {
    
    private var fillStyle: S
    private var firstThumb: T1
    private var secondThumb: T2

    private var maxWidth: Double
    private var cornerRadius: Double
    private var bounds: ClosedRange<Double>
    private var step: Double?

    @Binding private var value: ClosedRange<Double>
    @State private var previousWidth: Double = 0
    @State private var firstThumbWidth: Double = 0
    @State private var secondThumbWidth: Double = 0
    @State private var isDragging: Bool = false

    @State private var positionX: CGFloat = 0
    
    var body: some View {
        let start = calculateTrackStart()
        let width = calculateTrackWidth()
        
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(fillStyle)
            .overlay(
                firstThumb
                    .gesture(
                        DragGesture(coordinateSpace: .global)
                            .onChanged { action in
                                isDragging = true
                                let newWidth = previousWidth - action.translation.width
                                let percentage = max(min(newWidth / maxWidth, 1), 0)
                                let valueDifference = percentageToValue(percentage)
                                self.value = max(min(roundToStep(value.upperBound - valueDifference), self.value.upperBound), self.bounds.lowerBound)...self.value.upperBound
                            }
                            .onEnded {_ in
                                isDragging = false
                                previousWidth = width
                            }
                    )
                    .overlay(content: {
                        GeometryReader { geometry in
                            DispatchQueue.main.async {
                                self.firstThumbWidth = geometry.size.width
                            }
                            return Color.clear
                        }
                    })
                    .offset(x: -firstThumbWidth/2)
                ,
                alignment: .leading
            )
            .overlay(
                secondThumb
                    .gesture(
                        DragGesture(coordinateSpace: .global)
                            .onChanged { action in
                                isDragging = true
                                let newWidth = previousWidth + action.translation.width
                                let percentage = max(min(newWidth / maxWidth, 1), 0)
                                let valueDifference = percentageToValue(percentage)
                                self.value = self.value.lowerBound...min(max(roundToStep(valueDifference + value.lowerBound), self.value.lowerBound), self.bounds.upperBound)
                            }
                            .onEnded {_ in
                                isDragging = false
                                previousWidth = width
                            }
                    )
                    .overlay(content: {
                        GeometryReader { geometry in
                            DispatchQueue.main.async {
                                self.secondThumbWidth = geometry.size.width
                            }
                            return Color.clear
                        }
                    })
                    .offset(x: secondThumbWidth/2),
                    alignment: .trailing
            )
            .frame(width: width)
            .offset(x: start)
            .onAppear {
                self.previousWidth = calculateTrackWidth()
            }
            .onChange(of: value, {
                guard !isDragging else { return }
                self.previousWidth = calculateTrackWidth()
            })
    }
     
    private func calculateTrackWidth() -> Double {
        maxWidth * ((value.upperBound - value.lowerBound) / (bounds.upperBound - bounds.lowerBound))
    }
    
    private func calculateTrackStart() -> Double {
        maxWidth * ((value.lowerBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound))
    }
    
    private func percentageToValue(_ percentage: Double) -> Double {
        (bounds.upperBound - bounds.lowerBound) * percentage
    }
    
    func roundToStep(_ value: Double) -> Double {
        guard let step = step else { return value }
        let diff = value - bounds.lowerBound
        let remainder = diff.remainder(dividingBy: step)
        let new = if abs(remainder - step) > remainder {
            value - remainder
        } else {
            value + (step - remainder)
        }
        return min(max(new, bounds.lowerBound), bounds.upperBound)
    }
}

extension ThumbView {
    init(value: Binding<ClosedRange<Double>>, in bounds: ClosedRange<Double>, step: Double.Stride?,  maxWidth: Double, cornerRadius: Double, fill: S, @ViewBuilder firstThumb: () -> T1, @ViewBuilder secondThumb: () -> T2) {
        self._value = value
        self.bounds = bounds
        self.step = step
        self.cornerRadius = cornerRadius
        self.fillStyle = fill
        self.maxWidth = maxWidth
        self.firstThumb = firstThumb()
        self.secondThumb = secondThumb()
    }
}

#if DEBUG
struct SliderDemo: View {
    @State private var value: ClosedRange<Double> = -20...20
    let range: ClosedRange<Double> = -50...50

    var body: some View {
        VStack(spacing: 48) {
            
            ItsukiSlider(value: $value, in: range, step: 2)
                .frame(height: 12)

            ItsukiSlider(value: $value, in: range, step: 2, barStyle: (16, 8), fillBackground: .linearGradient(colors: [.red, .blue], startPoint: .leading, endPoint: .trailing), fillTrack: .linearGradient(colors: [.orange, .green], startPoint: .leading, endPoint: .trailing), firstThumb: {
                Image(systemName: "xmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.all, 12)
                    .background(Circle().fill(.red))
                    .frame(width: 36, height: 36)
            }, secondThumb: {
                Image(systemName: "xmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.all, 12)
                    .background(Circle().fill(.black))
                    .frame(width: 36, height: 36)
            })

            Text("value: \(value)")
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray.opacity(0.2))
    }
}
#endif

#Preview {
    SliderDemo()
}
