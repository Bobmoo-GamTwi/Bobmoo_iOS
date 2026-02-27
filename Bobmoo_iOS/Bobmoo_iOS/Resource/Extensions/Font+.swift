import SwiftUI

extension Font {
    enum PretendardWeight: String {
        case black = "Black"
        case bold = "Bold"
        case extraBold = "ExtraBold"
        case semiBold = "SemiBold"
        case medium = "Medium"
        case regular = "Regular"
        case light = "Light"
        case extraLight = "ExtraLight"
        case thin = "Thin"

        var fontName: String {
            "Pretendard-\(rawValue)"
        }
    }

    static func pretendard(_ weight: PretendardWeight = .regular, size: CGFloat) -> Font {
        .custom(weight.fontName, size: size)
    }
}

enum BobmooFontName {
    case head_b_48
    case head_b_30
    case head_b_21
    case title_sb_30
    case body_sb_18
    case body_b_17
    case body_b_15
    case body_sb_15
    case body_m_15
    case body_m_11
    case body_sb_11
    case body_sb_12
    case body_sb_11_tight
    case body_sb_9
    case body_r_15
    case caption_r_15
    case widget_sb_7
    case widget_sb_12
    case widget_sb_14
    case widget_m_11
    case widget_r_11
    case widget_r_11_tight
    case widget_sb_11

    var weight: Font.PretendardWeight {
        switch self {
        case .head_b_48, .head_b_30, .head_b_21, .body_b_17, .body_b_15:
            return .bold
        case .body_m_15, .body_m_11, .widget_m_11:
            return .medium
        case .title_sb_30, .body_sb_18, .body_sb_15, .body_sb_11, .body_sb_12, .body_sb_11_tight, .body_sb_9, .widget_sb_7, .widget_sb_12, .widget_sb_14, .widget_sb_11:
            return .semiBold
        case .body_r_15, .caption_r_15, .widget_r_11, .widget_r_11_tight:
            return .regular
        }
    }

    var size: CGFloat {
        switch self {
        case .head_b_48:
            return 48
        case .head_b_30:
            return 30
        case .head_b_21:
            return 21
        case .title_sb_30:
            return 18
        case .body_sb_18:
            return 18
        case .body_b_17:
            return 17
        case .body_b_15:
            return 15
        case .body_sb_15:
            return 15
        case .body_m_15:
            return 15
        case .body_m_11:
            return 11
        case .body_sb_12:
            return 12
        case .body_sb_11, .body_sb_11_tight:
            return 11
        case .body_sb_9:
            return 9
        case .body_r_15:
            return 15
        case .caption_r_15:
            return 15
        case .widget_sb_7:
            return 7
        case .widget_sb_12:
            return 12
        case .widget_sb_14:
            return 14
        case .widget_m_11, .widget_r_11, .widget_r_11_tight, .widget_sb_11:
            return 11
        }
    }

    var letterSpacingPercent: CGFloat {
        switch self {
        case .head_b_48, .head_b_30:
            return 2
        case .head_b_21, .title_sb_30, .body_sb_18:
            return 5
        case .body_b_17, .body_b_15:
            return 4
        case .body_m_15, .body_m_11:
            return 4
        case .body_sb_15, .body_sb_11, .body_sb_12, .body_r_15, .caption_r_15:
            return 4
        case .body_sb_11_tight, .body_sb_9:
            return 2
        case .widget_sb_7:
            return 2
        case .widget_sb_12, .widget_sb_14:
            return 5
        case .widget_m_11, .widget_r_11, .widget_r_11_tight:
            return 2
        case .widget_sb_11:
            return 4
        }
    }

    var tracking: CGFloat {
        size * (letterSpacingPercent / 100)
    }

    var lineHeight: CGFloat {
        switch self {
        case .body_m_11:
            return 21
        case .widget_sb_7:
            return 21
        case .widget_m_11, .widget_r_11:
            return 20
        case .widget_r_11_tight:
            return 15
        default:
            return size
        }
    }

    var lineSpacing: CGFloat {
        max(0, lineHeight - size)
    }
}

func BobmooFont(_ name: BobmooFontName) -> Font {
    .pretendard(name.weight, size: name.size)
}

func BobmooTracking(_ name: BobmooFontName) -> CGFloat {
    name.tracking
}

func BobmooLineHeight(_ name: BobmooFontName) -> CGFloat {
    name.lineHeight
}

func BobmooLineSpacing(_ name: BobmooFontName) -> CGFloat {
    name.lineSpacing
}

private struct BobmooTypographyModifier: ViewModifier {
    let name: BobmooFontName
    let multiline: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if multiline {
            content
                .font(BobmooFont(name))
                .tracking(BobmooTracking(name))
                .lineSpacing(BobmooLineSpacing(name))
                .frame(minHeight: BobmooLineHeight(name), alignment: .leading)
        } else {
            content
                .font(BobmooFont(name))
                .tracking(BobmooTracking(name))
                .frame(height: BobmooLineHeight(name), alignment: .leading)
        }
    }
}

struct BobmooText: View {
    private let text: String
    private let style: BobmooFontName
    private let multiline: Bool

    init(_ text: String, style: BobmooFontName, multiline: Bool = false) {
        self.text = text
        self.style = style
        self.multiline = multiline
    }

    var body: some View {
        Text(text)
            .bobmooTypography(style, multiline: multiline)
    }
}

extension View {
    func bobmooFont(_ name: BobmooFontName) -> some View {
        font(BobmooFont(name))
            .tracking(BobmooTracking(name))
    }

    func bobmooTypography(_ name: BobmooFontName, multiline: Bool = false) -> some View {
        modifier(BobmooTypographyModifier(name: name, multiline: multiline))
    }
}
