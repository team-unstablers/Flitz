//
//  FZInlineTab.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/11/25.
//

import SwiftUI

struct FZTab: Identifiable, Hashable {
    let id: String
    let title: String
    
    init(id: String, title: String) {
        self.id = id
        self.title = title
    }
    
    static func == (lhs: FZTab, rhs: FZTab) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct FZInlineTab: View {
    let tabs: [FZTab]
    
    @Binding
    var selectedTabId: String
    
    var selectedTabIndex: Int {
        tabs.firstIndex { $0.id == selectedTabId } ?? 0
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.Grayscale.gray1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            GeometryReader { geom in
                RoundedRectangle(cornerRadius: 6)
                    .fill(.white)
                    .padding(4)
                    .frame(maxWidth: geom.size.width / CGFloat(tabs.count), maxHeight: .infinity)
                    .offset(x: (geom.size.width / CGFloat(tabs.count)) * CGFloat(selectedTabIndex))
                    .animation(.easeInOut, value: selectedTabIndex)
            }
            
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button {
                        selectedTabId = tab.id
                    } label: {
                        Text(tab.title)
                            .foregroundStyle(selectedTabId == tab.id ? Color.Brand.black0 : Color.Grayscale.gray6)
                            .font(.fzHeading3)
                            .semibold()
                            .frame(maxWidth: .infinity, maxHeight: 44)
                            .padding(.vertical, 8)
                    }
                }
            }
        }
            .frame(maxWidth: .infinity, maxHeight: 44)
    }
}


#if DEBUG
struct FZInlineTabPreview: View {
    @State
    private var selectedTabId: String = "tab1"
    
    var body: some View {
        FZInlineTab(
            tabs: [
                FZTab(id: "tab1", title: "Tab 1"),
                FZTab(id: "tab2", title: "Tab 2"),
                FZTab(id: "tab3", title: "Tab 3")
            ],
            selectedTabId: $selectedTabId
        )
        .padding(16)
    }
}

#endif

#Preview {
#if DEBUG
    FZInlineTabPreview()
#endif
}
