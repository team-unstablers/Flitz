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
    
    /*
    @State
    private var isInInteraction: Bool = false
    
    @State
    private var lastConvertTime: Date = Date.distantPast
     */
    
    @State
    private var isInteractionEnd = false
    
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
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), latitudinalMeters: 1000, longitudinalMeters: 1000)
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
                            Text(NSLocalizedString("ui.settings.safety.radius", comment: "반경"))
                        } minimumValueLabel: {
                            Text("300m")
                        } maximumValueLabel: {
                            Text("1000m")
                        }
                        
                        Button(NSLocalizedString("ui.settings.safety.zone.delete", comment: "안전 구역 삭제")) {
                            picked = nil
                        }
                            .foregroundStyle(.red)
                    }
                        .opacity(picked != nil ? 1.0 : 0.0)
                    
                    Text(NSLocalizedString("ui.settings.safety.location_select_instruction", comment: "위치를 길게 눌러서 선택하세요."))
                        .font(.fzMain)
                        .foregroundStyle(Color.Brand.black0)
                        .opacity(picked == nil ? 1.0 : 0.0)
                }
                
            
                MapReader { proxy in
                    Map(position: $position) {
                        if let p = picked {
                            Marker(coordinate: p) {
                                Text(String(format: NSLocalizedString("ui.settings.safety.safe_zone_marker", comment: "안전 구역\n(반경 %dm)"), Int(radius)))
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
                                /*
                                 이거 Sheet dismiss 동작이랑 충돌해서 앱 크래시남. ㅠ
                                 이렇게 하려면 아예 별도 화면으로 분리해야 할듯.
                                if case .second(true, let drag?) = value {
                                    let now = Date()
                                    let timeInterval = now.timeIntervalSince(lastConvertTime)
                                    
                                    // 5 fps
                                    guard timeInterval >= (1 / 5) else { return }
                                    
                                    if let coord = proxy.convert(drag.location, from: .local) {
                                        if (!isInInteraction) {
                                            isInInteraction = true
                                        }
                                        
                                        lastConvertTime = now
                                        picked = coord
                                    }
                                }
                                 */
                                
                                if isInteractionEnd {
                                    return
                                }
                                
                                if case .second(true, let drag?) = value,
                                   let coord = proxy.convert(drag.location, from: .local) {
                                    picked = coord
                                    isInteractionEnd = true
                                }

                            }
                            .onEnded { value in
                                // isInInteraction = false
                                isInteractionEnd = false
                            }
                    )
                }
                .cornerRadius(12)
                
                Button(NSLocalizedString("ui.settings.safety.location.move_to_current", comment: "현재 위치로 이동")) {
                    position = .userLocation(fallback: .automatic)
                }
                .padding(.top, 4)
            }
            .padding()
            .toolbarVisibility(.visible, for: .navigationBar)
            .navigationTitle(NSLocalizedString("ui.safety.zone_settings.page_title", comment: "안전 구역 설정"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("ui.common.cancel", comment: "취소")) {
                        dismissHandler()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("ui.common.done", comment: "완료")) {
                        submitHandler(picked, radius)
                    }
                }
            }
        }
        .interactiveDismissDisabled()
    }
}

#Preview {
    VStack {
        
    }.sheet(isPresented: .constant(true)) {
        WaveSafetyZoneSettingsLocationSheet()
    }
}
