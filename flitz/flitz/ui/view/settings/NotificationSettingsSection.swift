//
//  WaveSafetyZoneSettingsSection.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/15/25.
//

import SwiftUI

class FZIntermediateUserSettings: ObservableObject {
    @Published
    var messagingNotificationsEnabled: Bool = false
    
    @Published
    var matchNotificationsEnabled: Bool = false
    
    @Published
    var noticeNotificationsEnabled: Bool = false
    
    @Published
    var marketingNotificationsEnabled: Bool = false
    
    @Published
    var marketingNotificationsEnabledAt: Date? = nil
    
    static func from(_ settings: FZUserSettings) -> FZIntermediateUserSettings {
        let intermediate = FZIntermediateUserSettings()
        
        intermediate.messagingNotificationsEnabled = settings.messaging_notifications_enabled
        intermediate.matchNotificationsEnabled = settings.match_notifications_enabled
        intermediate.noticeNotificationsEnabled = settings.notice_notifications_enabled
        intermediate.marketingNotificationsEnabled = settings.marketing_notifications_enabled
        intermediate.marketingNotificationsEnabledAt = settings.marketing_notifications_enabled_at?.asISO8601Date
        
        return intermediate
    }
    
    func toArgs() -> FZUserSettings {
        return FZUserSettings(messaging_notifications_enabled: messagingNotificationsEnabled,
                              match_notifications_enabled: matchNotificationsEnabled,
                              notice_notifications_enabled: noticeNotificationsEnabled,
                              marketing_notifications_enabled: marketingNotificationsEnabled,
                              marketing_notifications_enabled_at: nil)
    }
}

@MainActor
class NotificationSettingsSectionViewModel: ObservableObject {
    @Published
    var busy = false
    
    @Published
    var busyInitial = true
    
    @Published
    var intermediate = FZIntermediateUserSettings()
    
    var apiClient: FZAPIClient {
        RootAppState.shared.client
    }
    
    func loadSettings() async {
        defer {
            busy = false
            busyInitial = false
        }
        busy = true
        
        guard let response = try? await apiClient.selfSettings() else {
            #warning("FIXME: 잘못된 오류 처리")
            return
        }
        
        self.intermediate = FZIntermediateUserSettings.from(response)
    }
    
    func saveSettings() async {
        defer { busy = false }
        busy = true
        
        let args = intermediate.toArgs()
        
        guard let response = try? await apiClient.saveSelfSettings(args) else {
            #warning("FIXME: 잘못된 오류 처리")
            return
        }
        
        self.intermediate = FZIntermediateUserSettings.from(response)
    }
    
}

struct NotificationSettingsSection: View {
    @StateObject
    private var viewModel = NotificationSettingsSectionViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            FZPageSectionTitle(title: "ui.settings.notification.title")
            if viewModel.busyInitial {
                ProgressView()
                    .padding(.vertical, 8)
            } else {
                FZPageSectionItem("ui.settings.notification.enable_messaging_notifications") {
                    Toggle("", isOn: $viewModel.intermediate.messagingNotificationsEnabled)
                        .disabled(viewModel.busy)
                }
                FZPageSectionItem("ui.settings.notification.enable_match_notifications") {
                    Toggle("", isOn: $viewModel.intermediate.matchNotificationsEnabled)
                        .disabled(viewModel.busy)
                }
                FZPageSectionItem("ui.settings.notification.enable_notice_notifications") {
                    Toggle("", isOn: $viewModel.intermediate.noticeNotificationsEnabled)
                        .disabled(viewModel.busy)
                }
                FZPageSectionItem("ui.settings.notification.enable_marketing_notifications") {
                    Toggle("", isOn: $viewModel.intermediate.marketingNotificationsEnabled)
                        .disabled(viewModel.busy)
                }
            }
        }
        .animation(.spring, value: viewModel.busyInitial)
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
