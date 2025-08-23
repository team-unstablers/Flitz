//
//  CollapseableUserProfile.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/23/25.
//

import SwiftUI

struct CollapseableUserProfile: View {
    let profile: FZUser
    
    var dismiss: (() -> Void)? = nil
    
    @StateObject
    var profileGeometryHelper = UserProfileModalBodyGeometryHelper()

    @State
    private var isProfileCollapsed: Bool = true
    @State
    private var dragOffset2: CGSize = .zero
    @State
    private var extraSpacing: CGFloat = 0.0
    @State
    private var profileOpacity: Double = 0.0
    
    var body: some View {
        UserProfileModalBody(
            profile: profile,
            geometryHelper: profileGeometryHelper,
            extraSpacing: extraSpacing,
            profileImageOpacity: profileOpacity
        ) {
        }
        .opacity(profileOpacity.clamp(inRange: 0.0...1.0, outRange: 0.7...1.0))
        .offset(y: isProfileCollapsed ? profileGeometryHelper.contentAreaSize.height : 0)
        .offset(y: dragOffset2.height)
        .animation(.interactiveSpring(), value: isProfileCollapsed)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if isProfileCollapsed {
                        if (value.translation.height < 0) {
                            let translationHeight: CGFloat = abs(value.translation.height)
                            let contentHeight: CGFloat = profileGeometryHelper.contentAreaSize.height
                            
                            if translationHeight > contentHeight {
                                let extraSpacing = (translationHeight - contentHeight) * 0.25
                                let offsetY = contentHeight
                                
                                dragOffset2 = CGSize(width: 0, height: -offsetY)
                                self.extraSpacing = extraSpacing
                            } else {
                                dragOffset2 = value.translation
                            }
                            
                            let progress = min(1.0, max(0, abs(value.translation.height) / 200))
                            profileOpacity = progress
                        } else {
                            dragOffset2 = value.translation
                        }
                    } else {
                        if (value.translation.height > 0) {
                            dragOffset2 = value.translation
                            
                            let progress = min(1.0, max(0, abs(value.translation.height) / 200))
                            profileOpacity = 1.0 - progress
                        } else {
                            let translationHeight: CGFloat = abs(value.translation.height)
                            let extraSpacing = translationHeight * 0.25
                            
                            self.extraSpacing = extraSpacing
                        }
                    }
                    
                    // let progress = min(1.0, max(0, value.translation.height / 300))
                    // opacity = 1.0 - (progress * 0.5)
                }
                .onEnded { value in
                    if isProfileCollapsed {
                        withAnimation(.interactiveSpring()) {
                            extraSpacing = 0
                            
                            if value.translation.height < -80 {
                                isProfileCollapsed = false
                                profileOpacity = 1.0
                                dragOffset2 = .zero
                            } else if value.translation.height > 80 {
                                profileOpacity = 0
                                self.dismiss?()
                            } else {
                                dragOffset2 = .zero
                                profileOpacity = 0
                            }
                        }
                    } else {
                        withAnimation(.interactiveSpring()) {
                            extraSpacing = 0
                            
                            if value.translation.height > 80 {
                                isProfileCollapsed = true
                                profileOpacity = 0
                                dragOffset2 = .zero
                            } else {
                                profileOpacity = 1.0
                                dragOffset2 = .zero
                            }
                        }
                        
                    }
                }
        )
    }
}
