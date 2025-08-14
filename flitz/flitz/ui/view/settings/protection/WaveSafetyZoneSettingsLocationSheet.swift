//
//  WaveSafetyZoneSettingsLocationSheet.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/15/25.
//

import SwiftUI
import MapKit

struct WaveSafetyZoneSettingsLocationSheet: View {
    @State
    private var position: MapCameraPosition
    
    @State
    private var picked: CLLocationCoordinate2D?
    
    @State
    private var radius: Double
    
    @State
    private var isInInteraction: Bool = false
    
    var dismissHandler: (() -> Void)
    var submitHandler: ((CLLocationCoordinate2D?, Double) -> Void)
    
    init(latitude: Double? = nil,
         longitude: Double? = nil,
         radius: Double = 300.0,
         dismissHandler: @escaping (() -> Void) = {},
         submitHandler: @escaping ((CLLocationCoordinate2D?, Double) -> Void) = { _, _ in }
    ) {
        self._radius = State(initialValue: radius)
        
        if let lat = latitude, let lon = longitude {
            self._picked = State(initialValue: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), latitudinalMeters: 1000, longitudinalMeters: 1500)
            self._position = State(initialValue: .region(region))
        } else {
            self._picked = State(initialValue: nil)
            self._position = State(initialValue: .userLocation(fallback: .automatic))
        }
        
        self.dismissHandler = dismissHandler
        self.submitHandler = submitHandler
    }

    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    VStack {
                        Slider(value: $radius, in: 300...1000, step: 100) {
                            Text("반경")
                        } minimumValueLabel: {
                            Text("300m")
                        } maximumValueLabel: {
                            Text("1000m")
                        }
                        
                        Button("끄기 구역 삭제") {
                            picked = nil
                        }
                            .foregroundStyle(.red)
                    }
                        .opacity(picked != nil ? 1.0 : 0.0)
                    
                    Text("위치를 길게 눌러서 선택하세요.")
                        .font(.fzMain)
                        .foregroundStyle(Color.Brand.black0)
                        .opacity(picked == nil ? 1.0 : 0.0)
                }
                
                MapReader { proxy in
                    Map(position: $position, interactionModes: isInInteraction ? [] : .all) {
                        if let p = picked {
                            Marker(coordinate: p) {
                                Text("Wave 끄기 구역\n(반경 \(Int(radius))m)")
                            }
                            MapCircle(center: p, radius: radius)               // ← 300m
                                .foregroundStyle(.blue.opacity(0.18))       // 채우기
                                .stroke(.blue, lineWidth: 2)                 // 테두리
                        }
                    }
                    // 길게 눌러서 좌표 찍기
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 0.25)
                            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
                            .onChanged { value in
                                if case .second(true, let drag?) = value,
                                   let coord = proxy.convert(drag.location, from: .local) {
                                    isInInteraction = true
                                    
                                    picked = coord     // 여기서 p.latitude, p.longitude 사용
                                }
                            }
                            .onEnded { _ in
                                isInInteraction = false
                            }
                    )
                }
                .cornerRadius(12)
                
                Button("현재 위치로 이동") {
                    position = .userLocation(fallback: .automatic)
                }
                .padding(.top, 4)
            }
            .padding()
            .toolbarVisibility(.visible, for: .navigationBar)
            .navigationTitle("Wave 끄기 구역 설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismissHandler()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        submitHandler(picked, radius)
                    }
                }
            }
        }
    }
}

#Preview {
    WaveSafetyZoneSettingsLocationSheet()
}
