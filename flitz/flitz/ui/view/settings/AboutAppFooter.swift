//
//  AboutAppHeader.swift
//  reazure
//
//  Created by Gyuhwan Park on 11/16/24.
//

import SwiftUI


fileprivate struct AboutAppFooterBackground: View {
    static let backgroundGradient: Gradient = Gradient(colors: [
        Color(hex: 0xF2EC2A),
        Color(hex: 0xFF9500)
    ])

    var body: some View {
        LinearGradient(gradient: Self.backgroundGradient, startPoint: .top, endPoint: .bottom)
    }
}


struct AboutAppFooter: View {
    var body: some View {
        VStack(alignment: .leading) {
            (Text(Image(systemName: "exclamationmark.triangle.fill")) + Text(" ") + Text(LocalizedStringKey("ui.about_app_footer.warning_title")))
                .font(.heading3)
                .bold()
                .foregroundStyle(.black.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)
            
            Group {
                Text(LocalizedStringKey("ui.about_app_footer.outing_warning"))
                Text(LocalizedStringKey("ui.about_app_footer.reverse_engineering_warning"))
            }
                .font(.small)
                .foregroundStyle(.black.opacity(0.8))

            Group {
                Text(LocalizedStringKey("ui.about_app_footer.oss_notice"))
                Text(LocalizedStringKey("ui.about_app_footer.oss_license_info"))
            }
                .font(.small)
                .foregroundStyle(.black.opacity(0.8))
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.Grayscale.gray0.opacity(0.6))
        .tintColor(.blue)
    }
}

#Preview {
    AboutAppFooter()
}
