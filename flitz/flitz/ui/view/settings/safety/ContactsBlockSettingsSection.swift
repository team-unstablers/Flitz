//
//  WaveSafetyZoneSettingsSection.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/15/25.
//

import SwiftUI

@MainActor
class ContactsBlockSettingsSectionViewModel: ObservableObject {
    @Published
    var busy = false
    
    @Published
    var busyInitial = true
    
    @Published
    var enabled: Bool = false

    var apiClient: FZAPIClient {
        RootAppState.shared.client
    }
    
    func reflectEnabled() async {
        await ContactsBlockerTask.setEnabled(enabled)
        await saveSettings()
    }
    
    func removeAll() async {
        try? await apiClient.contactTriggerDeleteAll()
    }
    
    func loadSettings() async {
        defer {
            busy = false
            busyInitial = false
        }
        busy = true
        
        guard let response = try? await apiClient.contactTriggerEnabled() else {
            #warning("FIXME: 잘못된 오류 처리")
            return
        }
        
        self.enabled = response.is_enabled
    }
    
    func saveSettings() async {
        defer { busy = false }
        busy = true
        
        let args = FZContactsTriggerEnabled(is_enabled: self.enabled)
        
        guard let response = try? await apiClient.setContactTriggerEnabled(args) else {
            #warning("FIXME: 잘못된 오류 처리")
            return
        }
        
        self.enabled = response.is_enabled
    }
    
}

struct ContactsBlockSettingsSection: View {
    @StateObject
    private var viewModel = ContactsBlockSettingsSectionViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            FZPageSectionTitle(title: "연락처 미리 차단")
            if viewModel.busyInitial {
                ProgressView()
                    .padding(.vertical, 8)
            } else {
                FZPageSectionItem("휴대폰 연락처에 등록된 사람들을 미리 차단하기") {
                    Toggle("", isOn: $viewModel.enabled)
                }
                
                /*
                FZPageSectionActionItem("차단된 연락처 목록") {
                    
                }
                 */
                
                if viewModel.enabled {
                    FZPageSectionActionItem("지금 연락처 동기화하기") {
                        Task {
                            await ContactsBlockerTask().execute()
                        }
                    }
                } else {
                    FZPageSectionActionItem("연락처를 서버로부터 모두 삭제하고 차단 해제하기") {
                        Task {
                            await viewModel.removeAll()
                        }
                    }
                }

                /*
                FZPageSectionActionItem("이 기능에 대한 도움말 보기") {
                    
                }
                 */
                
                FZPageSectionNote {
                    VStack(alignment: .leading) {
                        Text("이 기능을 사용하면, 연락처에 등록된 사람이 추후 Flitz 서비스에 가입하거나, Flitz 앱을 켠 상태로 마주치게 되더라도 서로를 확인할 수 없게 됩니다.".byCharWrapping)
                        
                        (Text(Image(systemName: "exclamationmark.triangle.fill")) + Text(" ") + Text("안내"))
                            .font(.heading3)
                            .bold()
                            .foregroundStyle(.black.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                        
                        Text("이 기능을 사용하면 연락처 정보가 ".byCharWrapping) + Text("복호화 불가능한 형태로 해시 처리되어 Flitz 서버에 저장됩니다.".byCharWrapping).bold() + Text(" 또한, ".byCharWrapping) + Text("전화번호를 제외한 연락처 필드 (이름, 이메일 등)은 Flitz 서버에 저장되지 않습니다.").bold()
                        
                        Text("[해시 (단방향 암호화)란 무엇인가요?](https://docs.flitz.cards/help/safety/what-is-hashing.ko.html)")
                            .font(.small)
                            .padding(.vertical, 4)
                    }
                }
            }
        }
        .animation(.spring, value: viewModel.busyInitial)
        .onChange(of: viewModel.enabled) { _, newValue in
            Task {
                await viewModel.reflectEnabled()
            }
        }
        .onAppear {
            Task {
                await viewModel.loadSettings()
            }
        }
        /*
        .onReceive(viewModel.intermediate.objectWillChange) {
            Task {
                await viewModel.saveSettings()
            }
        }
         */
    }
}
