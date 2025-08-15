//
//  WaveSafetyZoneSettingsSection.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/15/25.
//

import SwiftUI

class FZIntermediateWaveSafetyZoneSettings: ObservableObject, Equatable, Hashable {
    @Published
    var latitude: Double? = nil
    
    @Published
    var longitude: Double? = nil
    
    @Published
    var radius: Double = 300.0
    
    @Published
    var isEnabled = false
    
    @Published
    var enableWaveAfterExit = true
    
    static func from(_ settings: FZUserWaveSafetyZone) -> FZIntermediateWaveSafetyZoneSettings {
        let intermediate = FZIntermediateWaveSafetyZoneSettings()
        
        intermediate.latitude = settings.latitude
        intermediate.longitude = settings.longitude
        intermediate.radius = settings.radius
        intermediate.isEnabled = settings.is_enabled
        intermediate.enableWaveAfterExit = settings.enable_wave_after_exit
        
        return intermediate
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
        hasher.combine(radius)
        hasher.combine(isEnabled)
        hasher.combine(enableWaveAfterExit)
    }
    
    static func == (lhs: FZIntermediateWaveSafetyZoneSettings, rhs: FZIntermediateWaveSafetyZoneSettings) -> Bool {
        return lhs.latitude == rhs.latitude &&
               lhs.longitude == rhs.longitude &&
               lhs.radius == rhs.radius &&
               lhs.isEnabled == rhs.isEnabled &&
               lhs.enableWaveAfterExit == rhs.enableWaveAfterExit
    }
}

@MainActor
class WaveSafetyZoneSettingsSectionViewModel: ObservableObject {
    @Published
    var busy = false
    
    @Published
    var busyInitial = true
    
    @Published
    var intermediate = FZIntermediateWaveSafetyZoneSettings()
    
    @Published
    var locationSheetPresented = false

    var apiClient: FZAPIClient {
        RootAppState.shared.client
    }
    
    func loadSettings() async {
        defer {
            busy = false
            busyInitial = false
        }
        busy = true
        
        do {
            let settings = try await apiClient.selfWaveSafetyZone()
            self.intermediate = FZIntermediateWaveSafetyZoneSettings.from(settings)
        } catch {
            #warning("FIXME: 오류 처리가 완전하지 않습니다")
            print("[WaveSafetyZoneSettings] Failed to load settings: \(error)")
        }
    }
    
    func saveSettings() async {
        defer { busy = false }
        busy = true
        
        let args = FZUserWaveSafetyZone(latitude: intermediate.latitude,
                                        longitude: intermediate.longitude,
                                        radius: intermediate.radius,
                                        is_enabled: intermediate.isEnabled,
                                        enable_wave_after_exit: intermediate.enableWaveAfterExit)
        
        do {
            let settings = try await apiClient.patchSelfWaveSafetyZone(args)
            self.intermediate = FZIntermediateWaveSafetyZoneSettings.from(settings)
        } catch {
            #warning("FIXME: 오류 처리가 완전하지 않습니다")
            print("[WaveSafetyZoneSettings] Failed to save settings: \(error)")
        }
    }
        
}

struct WaveSafetyZoneSettingsSection: View {
    @StateObject
    private var viewModel = WaveSafetyZoneSettingsSectionViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            FZPageSectionTitle(title: "자동으로 Wave 끄기 (베타)")
            if viewModel.busyInitial {
                ProgressView()
                    .padding(.vertical, 8)
            } else {
                FZPageSectionItem("자동으로 Wave 끄기 (베타)") {
                    Toggle("", isOn: $viewModel.intermediate.isEnabled)
                }
                FZPageSectionItem("장소에서 벗어나면 다시 Wave 켜기") {
                    Toggle("", isOn: $viewModel.intermediate.enableWaveAfterExit)
                }
                FZPageSectionActionItem("위치 지정하기") {
                    viewModel.locationSheetPresented = true
                }
                
                
                FZPageSectionNote() {
                    if viewModel.intermediate.isEnabled && (viewModel.intermediate.latitude == nil || viewModel.intermediate.longitude == nil) {
                        (Text("아직 위치를 지정하지 않았습니다!").bold() + Text(" '위치 지정하기' 버튼을 눌러 위치를 지정하지 않으면, 아무런 효과가 없을 것입니다.".byCharWrapping))
                            .padding(.bottom, 4)
                    }
                    
                    Text("특정 장소에 도착하면, 자동으로 Wave를 끄고 오프라인 상태로 전환합니다. 오프라인 상태에서는 상대방이 당신을 발견하거나 Wave할 수 없게 됩니다.".byCharWrapping)
                }
            }
        }
        .animation(.spring, value: viewModel.busyInitial)
        .sheet(isPresented: $viewModel.locationSheetPresented) {
            WaveSafetyZoneSettingsLocationSheet(latitude: viewModel.intermediate.latitude,
                                                longitude: viewModel.intermediate.longitude,
                                                radius: viewModel.intermediate.radius) {
                viewModel.locationSheetPresented = false
            } submitHandler: { coord, radius in
                viewModel.intermediate.latitude = coord?.latitude
                viewModel.intermediate.longitude = coord?.longitude
                
                viewModel.intermediate.radius = radius
                
                viewModel.locationSheetPresented = false
            }
            .interactiveDismissDisabled()
        }
        .onAppear {
            Task {
                await viewModel.loadSettings()
            }
        }
        .onReceive(viewModel.intermediate.objectWillChange) {
            Task {
                await viewModel.saveSettings()
            }
        }
    }
}
