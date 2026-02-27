import SwiftUI
import WidgetKit

struct DietWidgetView: View {
    let entry: DietEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                IosWidget1View(entry: entry)
            case .systemMedium:
                IosWidget2View(entry: entry)
            default:
                EmptyView()
            }
        }
        .containerBackground(for: .widget) { Color.white }
    }
}

// MARK: - ios_widget_1 (Small)

private struct IosWidget1View: View {
    let entry: DietEntry

    var body: some View {
        ZStack(alignment: .topLeading) {
            WidgetText.date(dateText)
                .foregroundStyle(WidgetColor.gray3)
                .frame(height: 21, alignment: .leading)
                .offset(x: 16, y: 11)

            WidgetText.title(selectedCafeteriaInfo.name)
                .foregroundStyle(.black)
                .offset(x: 16, y: 31)

            WidgetText.date(selectedCafeteriaInfo.hours)
                .foregroundStyle(WidgetColor.gray3)
                .frame(height: 21, alignment: .leading)
                .offset(x: 65, y: 30)

            WidgetMenuList(menus: menusForCafeteria, maxWidth: 119)
                .offset(x: 17, y: 55)

            WidgetStatusBadge(status: status(for: selectedCafeteriaInfo.hours))
                .offset(x: 93, y: 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var selectedCafeteriaInfo: CafeteriaInfo {
        let selectedName = UserDefaults.bobmooShared.string(forKey: "selectedCafeteria") ?? "학생식당"
        return entry.cafeterias.first(where: { $0.name == selectedName }) ?? entry.cafeterias.first ?? CafeteriaInfo(name: selectedName, hours: "미운영", menus: ["미운영"])
    }

    private var menusForCafeteria: [WidgetCourseMenu] {
        WidgetCourseMenu.parse(from: selectedCafeteriaInfo.menus)
    }

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일 EEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: entry.date)
    }

    private func status(for hours: String) -> WidgetOperationStatus {
        guard let period = hours.widgetOperationPeriod(on: entry.date) else {
            return .ended
        }
        return WidgetOperationStatusResolver.resolve(now: .now, period: period)
    }
}

// MARK: - ios_widget_2 (Medium)

private struct IosWidget2View: View {
    let entry: DietEntry

    var body: some View {
        ZStack(alignment: .topLeading) {
            WidgetText.date(dateText)
                .foregroundStyle(WidgetColor.gray3)
                .frame(height: 21, alignment: .leading)
                .offset(x: 19, y: 12)

            WidgetText.mealTime(entry.mealTime)
                .foregroundStyle(.black)
                .offset(x: 19, y: 30)

            WidgetText.date(hoursText)
                .foregroundStyle(WidgetColor.gray3)
                .frame(height: 21, alignment: .leading)
                .offset(x: 48, y: 31)

            WidgetCafeteriaColumn(info: cafeteria(for: "학생식당"))
                .offset(x: 20, y: 56)

            WidgetCafeteriaColumn(info: cafeteria(for: "교직원식당"))
                .offset(x: 126, y: 56)

            WidgetCafeteriaColumn(info: cafeteria(for: "생활관식당"))
                .offset(x: 228, y: 56)

            WidgetStatusBadge(status: status(for: hoursText))
                .offset(x: 268, y: 19)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func cafeteria(for name: String) -> CafeteriaInfo {
        entry.cafeterias.first(where: { $0.name == name }) ?? CafeteriaInfo(name: name, hours: hoursText, menus: ["미운영"])
    }

    private var hoursText: String {
        let selectedName = UserDefaults.bobmooShared.string(forKey: "selectedCafeteria") ?? "학생식당"
        return entry.cafeterias.first(where: { $0.name == selectedName })?.hours ?? entry.cafeterias.first?.hours ?? "미운영"
    }

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일 EEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: entry.date)
    }

    private func status(for hours: String) -> WidgetOperationStatus {
        guard let period = hours.widgetOperationPeriod(on: entry.date) else {
            return .ended
        }
        return WidgetOperationStatusResolver.resolve(now: .now, period: period)
    }
}

private struct WidgetCafeteriaColumn: View {
    let info: CafeteriaInfo

    var body: some View {
        ZStack(alignment: .topLeading) {
            WidgetText.title(info.name)
                .foregroundStyle(.black)

            WidgetMenuList(menus: WidgetCourseMenu.parse(from: info.menus), maxWidth: 93)
                .offset(x: 0, y: 17)
        }
        .frame(width: 93, height: 84, alignment: .topLeading)
    }
}

// MARK: - Menu List

private struct WidgetMenuList: View {
    let menus: [WidgetCourseMenu]
    let maxWidth: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(WidgetColor.gray5)
                .frame(width: 1)

            VStack(alignment: .leading, spacing: 2) {
                ForEach(WidgetCourseMenu.fillToThree(menus), id: \.self) { item in
                    WidgetMenuRow(item: item)
                        .frame(height: 20, alignment: .topLeading)
                }
            }
            .padding(.leading, 6)
        }
        .frame(width: maxWidth, height: 64, alignment: .topLeading)
    }
}

private struct WidgetMenuRow: View {
    let item: WidgetCourseMenu

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            WidgetText.course(item.course)
                .foregroundStyle(.black)
                .frame(width: 8, alignment: .leading)

            if item.course == "B" {
                WidgetText.menu(item.menu, tight: true)
                    .foregroundStyle(.black)
                    .padding(.leading, 4)
                    .padding(.top, 3)
            } else {
                WidgetText.menu(item.menu, tight: false)
                    .foregroundStyle(.black)
                    .padding(.leading, 5)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Status Badge

private struct WidgetStatusBadge: View {
    let status: WidgetOperationStatus

    var body: some View {
        WidgetText.badge(status.title)
            .foregroundStyle(.white)
            .frame(width: 50, height: 24)
            .background(WidgetColor.blue)
            .clipShape(Capsule())
    }
}

// MARK: - Typography / Colors

private enum WidgetColor {
    static let blue = Color(red: 0x00 / 255.0, green: 0x64 / 255.0, blue: 0xFB / 255.0)
    static let gray3 = Color(red: 0x61 / 255.0, green: 0x65 / 255.0, blue: 0x6F / 255.0)
    static let gray5 = Color(red: 0x8F / 255.0, green: 0x8F / 255.0, blue: 0x8F / 255.0)
}

private enum WidgetText {
    static func date(_ text: String) -> some View {
        Text(text)
            .font(.pretendard(.semiBold, size: 7))
            .tracking(7 * 0.02)
    }

    static func title(_ text: String) -> some View {
        Text(text)
            .font(.pretendard(.semiBold, size: 12))
            .tracking(12 * 0.05)
    }

    static func mealTime(_ text: String) -> some View {
        Text(text)
            .font(.pretendard(.semiBold, size: 14))
            .tracking(14 * 0.05)
    }

    static func course(_ text: String) -> some View {
        Text(text)
            .font(.pretendard(.medium, size: 11))
            .tracking(11 * 0.02)
            .frame(height: 20, alignment: .topLeading)
    }

    static func menu(_ text: String, tight: Bool) -> some View {
        Text(text)
            .font(.pretendard(.regular, size: 11))
            .tracking(11 * 0.02)
            .lineLimit(1)
            .truncationMode(.tail)
            .frame(height: tight ? 15 : 20, alignment: .topLeading)
    }

    static func badge(_ text: String) -> some View {
        Text(text)
            .font(.pretendard(.semiBold, size: 11))
            .tracking(11 * 0.04)
    }
}

private extension Font {
    enum PretendardWeight: String {
        case semiBold = "SemiBold"
        case medium = "Medium"
        case regular = "Regular"

        var fontName: String { "Pretendard-\(rawValue)" }
    }

    static func pretendard(_ weight: PretendardWeight, size: CGFloat) -> Font {
        .custom(weight.fontName, size: size)
    }
}

// MARK: - Operation Status

private struct WidgetOperationPeriod {
    let startAt: Date
    let endAt: Date
}

private enum WidgetOperationStatus: String {
    case before
    case active
    case ended

    var title: String {
        switch self {
        case .before: return "운영전"
        case .active: return "운영중"
        case .ended: return "운영종료"
        }
    }
}

private enum WidgetOperationStatusResolver {
    static func resolve(now: Date, period: WidgetOperationPeriod) -> WidgetOperationStatus {
        if now < period.startAt { return .before }
        if now <= period.endAt { return .active }
        return .ended
    }
}

private extension String {
    func widgetOperationPeriod(on day: Date, calendar: Calendar = .current) -> WidgetOperationPeriod? {
        guard !contains("미운영") else { return nil }

        let delimiters = CharacterSet(charactersIn: "-~")
        let parts = components(separatedBy: delimiters)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard parts.count == 2,
              let startAt = calendar.widgetDate(on: day, timeText: parts[0]),
              let endAt = calendar.widgetDate(on: day, timeText: parts[1]) else {
            return nil
        }

        return WidgetOperationPeriod(startAt: startAt, endAt: endAt)
    }
}

private extension Calendar {
    func widgetDate(on day: Date, timeText: String) -> Date? {
        let parts = timeText.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return nil }
        return date(bySettingHour: parts[0], minute: parts[1], second: 0, of: day)
    }
}

// MARK: - Menu Parsing

private struct WidgetCourseMenu: Hashable {
    let course: String
    let menu: String

    static func parse(from rawMenus: [String]) -> [WidgetCourseMenu] {
        let parsed = rawMenus.compactMap { raw -> WidgetCourseMenu? in
            if raw.contains("미운영") {
                return WidgetCourseMenu(course: "A", menu: "미운영")
            }

            let separators = [":", "："]
            for sep in separators {
                if let range = raw.range(of: sep) {
                    let left = raw[..<range.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
                    let right = raw[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
                    if !left.isEmpty, !right.isEmpty {
                        return WidgetCourseMenu(course: left, menu: right)
                    }
                }
            }

            return WidgetCourseMenu(course: "A", menu: raw.trimmingCharacters(in: .whitespacesAndNewlines))
        }

        return parsed.sorted { lhs, rhs in
            let order: [String: Int] = ["A": 0, "B": 1, "C": 2]
            return (order[lhs.course] ?? 99) < (order[rhs.course] ?? 99)
        }
    }

    static func fillToThree(_ menus: [WidgetCourseMenu]) -> [WidgetCourseMenu] {
        let normalized = menus.prefix(3)
        if normalized.count == 3 { return Array(normalized) }

        var result = Array(normalized)
        let needed = 3 - result.count
        for index in 0..<needed {
            let course = ["A", "B", "C"][min(result.count + index, 2)]
            result.append(WidgetCourseMenu(course: course, menu: "미운영"))
        }
        return result
    }
}

#Preview(as: .systemSmall) {
    DietWidget()
} timeline: {
    DietEntry(
        date: .now,
        mealTime: "아침",
        cafeterias: [
            CafeteriaInfo(
                name: "학생식당",
                hours: "08:00-09:30",
                menus: ["A: 돈가스*소스", "B: 어묵볶음, 김치콩나물국", "C: 요구르트"]
            ),
            CafeteriaInfo(
                name: "교직원식당",
                hours: "08:00-09:30",
                menus: ["A: 돈가스*소스", "B: 어묵볶음, 김치콩나물국", "C: 요구르트"]
            ),
            CafeteriaInfo(
                name: "생활관식당",
                hours: "08:00-09:30",
                menus: ["A: 돈가스*소스", "B: 어묵볶음, 김치콩나물국", "C: 요구르트"]
            )
        ]
    )
}

#Preview(as: .systemMedium) {
    DietWidget()
} timeline: {
    DietEntry(
        date: .now,
        mealTime: "아침",
        cafeterias: [
            CafeteriaInfo(
                name: "학생식당",
                hours: "08:00-09:30",
                menus: ["A: 돈가스*소스", "B: 어묵볶음, 김치콩나물국", "C: 요구르트"]
            ),
            CafeteriaInfo(
                name: "교직원식당",
                hours: "08:00-09:30",
                menus: ["A: 돈가스*소스", "B: 어묵볶음, 김치콩나물국", "C: 요구르트"]
            ),
            CafeteriaInfo(
                name: "생활관식당",
                hours: "08:00-09:30",
                menus: ["A: 돈가스*소스", "B: 어묵볶음, 김치콩나물국", "C: 요구르트"]
            )
        ]
    )
}
