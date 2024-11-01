//
//  RalewayFont.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 10/29/24.
//

import SwiftUI

struct RalewayFont: ViewModifier {
    
    @Environment(\.sizeCategory) var sizeCategory
    
    public enum TextStyle {
        case largeTitle
        case title
        case headline
        case subheadline
        case body
        case footnote
        case caption
    }
    
    var textStyle: TextStyle
    var fontSize: CGFloat? // Optional specific font size
        var fontWeight: Font.Weight?
    
    func body(content: Content) -> some View {
//        let scaledSize = UIFontMetrics.default.scaledValue(for: size)
//        return content.font(.custom(fontName, size: scaledSize))
        let scaledSize = UIFontMetrics.default.scaledValue(for: fontSize ?? defaultSize)
                return content
                    .font(.custom(fontName, size: scaledSize))
                    .fontWeight(fontWeight ?? defaultWeight)
    }
    
    private var fontName: String {
        switch textStyle {
        case .largeTitle:
            return "Raleway-Bold"
        case .title:
            return "Raleway-Bold"
        case .headline:
            return "Raleway-SemiBold"
        case .subheadline:
            return "Raleway-Regular"
        case .body:
            return "Raleway-Regular"
        case .footnote:
            return "Raleway-Medium"
        case .caption:
            return "Raleway-Light"
        }
    }
    
    private var size: CGFloat {
        switch textStyle {
        case .largeTitle:
            return 35
        case .title:
            return 21
        case .headline:
            return 19
        case .subheadline:
            return 18
        case .body:
            return 17
        case .footnote:
            return 16
        case .caption:
            return 14
        }
    }
    
    private var defaultSize: CGFloat {
        switch textStyle {
        case .largeTitle: return 35
        case .title: return 21
        case .headline: return 19
        case .subheadline: return 18
        case .body: return 17
        case .footnote: return 16
        case .caption: return 14
        }
    }
    
    private var defaultWeight: Font.Weight {
        switch textStyle {
        case .largeTitle, .title: return .bold
        case .headline: return .semibold
        case .subheadline, .body: return .regular
        case .footnote: return .medium
        case .caption: return .light
        }
    }
    
    private var relativeToTextStyle: Font.TextStyle {
        switch textStyle {
        case .largeTitle: return .largeTitle
        case .title: return .title2
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .footnote: return .footnote
        case .caption: return .caption
        }
    }
}

private extension RalewayFont.TextStyle {
    var uiFontTextStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title2
        case .headline: return .headline
        case .body: return .body
        case .subheadline: return .subheadline
        case .footnote: return .footnote
        case .caption: return .caption1
        }
    }
}

extension View {
//    func ralewayFont(_ textStyle: RalewayFont.TextStyle) -> some View {
//        self.modifier(RalewayFont(textStyle: textStyle))
//    }
    func ralewayFont(_ textStyle: RalewayFont.TextStyle, size: CGFloat? = nil, weight: Font.Weight? = nil) -> some View {
        self.modifier(RalewayFont(textStyle: textStyle, fontSize: size, fontWeight: weight))
    }
}
