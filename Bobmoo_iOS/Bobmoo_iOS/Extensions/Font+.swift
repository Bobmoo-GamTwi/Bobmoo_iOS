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
