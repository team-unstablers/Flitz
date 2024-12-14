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
    static let fzMain = UIFont(name: "Noto Sans KR", size: .fzFontSizeMain)!
    
    static let fzSmall = UIFont(name: "Noto Sans KR", size: .fzFontSizeSmall)!
    
    static let fzHeading1 = UIFont(name: "Noto Sans KR", size: .fzFontSizeHeading1)!
    static let fzHeading2 = UIFont(name: "Noto Sans KR", size: .fzFontSizeHeading2)!
    static let fzHeading3 = UIFont(name: "Noto Sans KR", size: .fzFontSizeHeading3)!
}

extension Font {
    static let fzMain: Font = .custom("Noto Sans KR", size: .fzFontSizeMain)
    
    static let fzSmall: Font = .custom("Noto Sans KR", size: .fzFontSizeSmall)
    
    static let fzHeading1: Font = .custom("Noto Sans KR", size: .fzFontSizeHeading1)
    static let fzHeading2: Font = .custom("Noto Sans KR", size: .fzFontSizeHeading2)
    static let fzHeading3: Font = .custom("Noto Sans KR", size: .fzFontSizeHeading3)

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
            Text("가나다라마바사 Heading 1")
                .font(.heading1)
                .bold()
            Text("이 편지는 영국에서 시작되어 영국에서 끝나는 편지입니다. 이 편지는 영국에서 시작되어 영국에서 끝나는 편지입니다. 이 편지는 영국에서 시작되어 영국에서 끝나는 편지입니다.")
                .font(.main)
        }
        VStack(alignment: .leading, spacing: 0) {
            Text("가나다라마바사 Heading 2")
                .font(.heading2)
                .bold()
            Text("이 편지는 일본에서 시작되어 일본에서 끝나는 편지입니다. 이 편지는 일본에서 시작되어 일본에서 끝나는 편지입니다. 이 편지는 일본에서 시작되어 일본에서 끝나는 편지입니다.")
                .font(.main)
        }
        
        VStack(alignment: .leading, spacing: 0) {
            Text("가나다라마바사 Heading 3")
                .font(.heading3)
                .bold()
            Text("이 편지는 중국에서 시작되어 중국에서 끝나는 편지입니다. 이 편지는 중국에서 시작되어 중국에서 끝나는 편지입니다. 이 편지는 중국에서 시작되어 중국에서 끝나는 편지입니다.")
                .font(.main)
        }
        
        VStack(alignment: .leading, spacing: 0) {
            Text("⚠️ 경고")
                .font(.small)
                .bold()
                .foregroundStyle(Color.Subcolor.red)
            Text("이 편지는 한국에 도달하지 않을 수도 있습니다.")
                .font(.small)
                .foregroundStyle(Color.Grayscale.gray7)
        }
        
        VStack(alignment: .leading, spacing: 0) {
            Text("✅ 성공")
                .font(.small)
                .bold()
                .foregroundStyle(Color.Subcolor.green)
            Text("이 편지는 무사히 한국에 도달하였습니다.")
                .font(.small)
                .foregroundStyle(Color.Grayscale.gray7)
        }
    }
    .padding()
}
