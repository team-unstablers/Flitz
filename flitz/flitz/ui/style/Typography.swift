//
//  Typography.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/14/24.
//

import SwiftUI

extension CGFloat {
    static let fzFontSizeMain: CGFloat = 14
    static let fzFontSizeSmall: CGFloat = 12
    
    static let fzFontSizeHeading1: CGFloat = 26
    static let fzFontSizeHeading2: CGFloat = 20
    static let fzFontSizeHeading3: CGFloat = 16
    
    static let fzLineHeightMain: CGFloat = 22
    static let fzLineHeightSmall: CGFloat = 18
    
    static let fzLineHeightHeading1: CGFloat = 40
    static let fzLineHeightHeading2: CGFloat = 30
    static let fzLineHeightHeading3: CGFloat = 24
}

/// 행간은 폰트 크기 x 1.5(반올림 짝수)을 규칙으로 계산됩니다.
extension UIFont {
    static let fzMain = UIFont(name: "Pretendard Variable", size: .fzFontSizeMain)!
    
    static let fzSmall = UIFont(name: "Pretendard Variable", size: .fzFontSizeSmall)!
    
    static let fzHeading1 = UIFont(name: "Pretendard Variable", size: .fzFontSizeHeading1)!
    static let fzHeading2 = UIFont(name: "Pretendard Variable", size: .fzFontSizeHeading2)!
    static let fzHeading3 = UIFont(name: "Pretendard Variable", size: .fzFontSizeHeading3)!
    
    // https://stackoverflow.com/questions/34499735/how-to-apply-bold-and-italics-to-an-nsmutableattributedstring-range
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        // create a new font descriptor with the given traits
        guard let fd = fontDescriptor.withSymbolicTraits(traits) else {
            // the given traits couldn't be applied, return self
            return self
        }
            
        // return a new font with the created font descriptor
        return UIFont(descriptor: fd, size: pointSize)
    }

    func italics() -> UIFont {
        return withTraits(.traitItalic)
    }

    func bold() -> UIFont {
        return withTraits(.traitBold)
    }

    func boldItalics() -> UIFont {
        return withTraits([ .traitBold, .traitItalic ])
    }
    
    static func setupUINavigationBarTypography() {
        if #available(iOS 26.0, *) {
            return
        } else {
            let appearance = UINavigationBar.appearance()
            
            appearance.largeTitleTextAttributes = [
                .font: UIFont.fzHeading1.bold(),
            ]
            
            appearance.titleTextAttributes = [
                .font: UIFont.fzHeading3.bold(),
            ]
            
            let navigationBarAppearance = UINavigationBarAppearance()
            
            navigationBarAppearance.configureWithDefaultBackground()
            
            navigationBarAppearance.largeTitleTextAttributes = [
                .font: UIFont.fzHeading1.bold(),
            ]
            
            navigationBarAppearance.titleTextAttributes = [
                .font: UIFont.fzHeading3.bold(),
            ]
            
            navigationBarAppearance.backButtonAppearance.normal.titleTextAttributes = [
                .font: UIFont.fzMain,
            ]
            
            
            let scrollEdgeAppearance = UINavigationBarAppearance()
            
            scrollEdgeAppearance.configureWithOpaqueBackground()
            
            scrollEdgeAppearance.largeTitleTextAttributes = [
                .font: UIFont.fzHeading1.bold(),
            ]
            
            scrollEdgeAppearance.titleTextAttributes = [
                .font: UIFont.fzHeading3.bold(),
            ]
            
            scrollEdgeAppearance.backButtonAppearance.normal.titleTextAttributes = [
                .font: UIFont.fzMain,
            ]
            
            scrollEdgeAppearance.shadowColor = .clear
            
            appearance.standardAppearance = navigationBarAppearance
            appearance.compactAppearance = navigationBarAppearance
            appearance.scrollEdgeAppearance = scrollEdgeAppearance
            appearance.compactScrollEdgeAppearance = scrollEdgeAppearance
        }
    }
}

extension Font {
    static let fzMain: Font = .custom("Pretendard Variable", size: .fzFontSizeMain)
    
    static let fzSmall: Font = .custom("Pretendard Variable", size: .fzFontSizeSmall)
    
    static let fzHeading1: Font = .custom("Pretendard Variable", size: .fzFontSizeHeading1)
    static let fzHeading2: Font = .custom("Pretendard Variable", size: .fzFontSizeHeading2)
    static let fzHeading3: Font = .custom("Pretendard Variable", size: .fzFontSizeHeading3)

}

enum FZFont {
    case main
    case small
    case heading1
    case heading2
    case heading3
    
    var size: CGFloat {
        switch self {
        case .main:
            return .fzFontSizeMain
        case .small:
            return .fzFontSizeSmall
        case .heading1:
            return .fzFontSizeHeading1
        case .heading2:
            return .fzFontSizeHeading2
        case .heading3:
            return .fzFontSizeHeading3
        }
    }
    
    var lineHeight: CGFloat {
        switch self {
        case .main:
            return .fzLineHeightMain
        case .small:
            return .fzLineHeightSmall
        case .heading1:
            return .fzLineHeightHeading1
        case .heading2:
            return .fzLineHeightHeading2
        case .heading3:
            return .fzLineHeightHeading3
        }
    }
    
    var uiFont: UIFont {
        switch self {
        case .main:
            return .fzMain
        case .small:
            return .fzSmall
        case .heading1:
            return .fzHeading1
        case .heading2:
            return .fzHeading2
        case .heading3:
            return .fzHeading3
        }
    }
    
    var font: Font {
        switch self {
        case .main:
            return .fzMain
        case .small:
            return .fzSmall
        case .heading1:
            return .fzHeading1
        case .heading2:
            return .fzHeading2
        case .heading3:
            return .fzHeading3
        }
    }
}

extension View {
    @ViewBuilder
    func font(_ font: FZFont) -> some View {
        self.font(font.font)
            .lineSpacing(font.lineHeight - font.uiFont.lineHeight)
            .padding(.vertical, (font.lineHeight - font.uiFont.lineHeight) / 2)
        
    }
}

#Preview {
    HStack {
        Group {
            Color.Brand.orange0
            Color.Brand.blue0
            Color.Brand.yellow0
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .frame(width: 64, height: 64)
    }
    HStack {
        Group {
            Color.Brand.green0
            Color.Brand.gray0
            Color.Brand.black0
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .frame(width: 64, height: 64)
    }
    
    VStack(alignment: .leading) {
        VStack(alignment: .leading, spacing: 0) {
            Text(NSLocalizedString("ui.style.typography.sample_heading1", comment: "가나다라마바사 Heading 1"))
                .font(.heading1)
                .bold()
            Text(NSLocalizedString("ui.style.typography.sample_body_england", comment: "이 편지는 영국에서 시작되어 영국에서 끝나는 편지입니다. 이 편지는 영국에서 시작되어 영국에서 끝나는 편지입니다. 이 편지는 영국에서 시작되어 영국에서 끝나는 편지입니다."))
                .font(.main)
        }
        VStack(alignment: .leading, spacing: 0) {
            Text(NSLocalizedString("ui.style.typography.sample_heading2", comment: "가나다라마바사 Heading 2"))
                .font(.heading2)
                .bold()
            Text(NSLocalizedString("ui.style.typography.sample_body_japan", comment: "이 편지는 일본에서 시작되어 일본에서 끝나는 편지입니다. 이 편지는 일본에서 시작되어 일본에서 끝나는 편지입니다. 이 편지는 일본에서 시작되어 일본에서 끝나는 편지입니다."))
                .font(.main)
        }
        
        VStack(alignment: .leading, spacing: 0) {
            Text(NSLocalizedString("ui.style.typography.sample_heading3", comment: "가나다라마바사 Heading 3"))
                .font(.heading3)
                .bold()
            Text(NSLocalizedString("ui.style.typography.sample_body_china", comment: "이 편지는 중국에서 시작되어 중국에서 끝나는 편지입니다. 이 편지는 중국에서 시작되어 중국에서 끝나는 편지입니다. 이 편지는 중국에서 시작되어 중국에서 끝나는 편지입니다."))
                .font(.main)
        }
        
        VStack(alignment: .leading, spacing: 0) {
            Text(NSLocalizedString("ui.style.typography.warning_sample", comment: "⚠️ 경고"))
                .font(.small)
                .bold()
                .foregroundStyle(Color.Subcolor.red)
            Text(NSLocalizedString("ui.style.typography.warning_message_sample", comment: "이 편지는 한국에 도달하지 않을 수도 있습니다."))
                .font(.small)
                .foregroundStyle(Color.Grayscale.gray7)
        }
        
        VStack(alignment: .leading, spacing: 0) {
            Text(NSLocalizedString("ui.style.typography.success_sample", comment: "✅ 성공"))
                .font(.small)
                .bold()
                .foregroundStyle(Color.Subcolor.green)
            Text(NSLocalizedString("ui.style.typography.success_message_sample", comment: "이 편지는 무사히 한국에 도달하였습니다."))
                .font(.small)
                .foregroundStyle(Color.Grayscale.gray7)
        }
    }
    .padding()
}
