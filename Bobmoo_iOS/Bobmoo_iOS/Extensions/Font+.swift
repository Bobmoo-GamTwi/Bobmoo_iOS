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
    case head_b_30
    case head_b_21
    case title_sb_30
    case body_sb_18
    case body_sb_11
    case body_sb_11_tight
    case body_sb_9
    case caption_r_15

    var weight: Font.PretendardWeight {
        switch self {
        case .head_b_30, .head_b_21:
            return .bold
        case .title_sb_30, .body_sb_18, .body_sb_11, .body_sb_11_tight, .body_sb_9:
            return .semiBold
        case .caption_r_15:
            return .regular
        }
    }

    var size: CGFloat {
        switch self {
        case .head_b_30:
            return 30
        case .head_b_21:
            return 21
        case .title_sb_30:
            return 18
        case .body_sb_18:
            return 18
        case .body_sb_11, .body_sb_11_tight:
            return 11
        case .body_sb_9:
            return 9
        case .caption_r_15:
            return 15
        }
    }

    var letterSpacingPercent: CGFloat {
        switch self {
        case .head_b_30:
            return 2
        case .head_b_21, .title_sb_30, .body_sb_18:
            return 5
        case .body_sb_11, .caption_r_15:
            return 4
        case .body_sb_11_tight, .body_sb_9:
            return 2
        }
    }

    var tracking: CGFloat {
        size * (letterSpacingPercent / 100)
    }
}

func BobmooFont(_ name: BobmooFontName) -> Font {
    .pretendard(name.weight, size: name.size)
}

func BobmooTracking(_ name: BobmooFontName) -> CGFloat {
    name.tracking
}

extension View {
    func bobmooFont(_ name: BobmooFontName) -> some View {
        font(BobmooFont(name))
            .tracking(BobmooTracking(name))
    }
}
