import SwiftUI

extension Color {
    init?(hexRGB: String) {
        var hex = hexRGB.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }

        guard hex.count == 6, let value = UInt64(hex, radix: 16) else {
            return nil
        }

        let red = Double((value & 0xFF0000) >> 16) / 255.0
        let green = Double((value & 0x00FF00) >> 8) / 255.0
        let blue = Double(value & 0x0000FF) / 255.0

        self = Color(red: red, green: green, blue: blue)
    }
}
