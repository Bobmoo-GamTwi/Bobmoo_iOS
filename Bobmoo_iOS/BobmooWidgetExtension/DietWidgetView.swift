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
        .containerBackground(for: .widget) { Color.bobmooWhite }
    }
}

// MARK: - ios_widget_1 (Small)

private struct IosWidget1View: View {
    let entry: DietEntry

    var body: some View {
        ZStack(alignment: .topLeading) {
            BobmooText(dateText, style: .widget_sb_7)
                .foregroundStyle(.bobmooGray3)
                .offset(x: 16, y: 11)

            BobmooText(selectedCafeteriaInfo.name, style: .widget_sb_12)
                .foregroundStyle(.bobmooBlack)
                .offset(x: 16, y: 31)

            BobmooText(selectedCafeteriaInfo.hours, style: .widget_sb_7)
                .foregroundStyle(.bobmooGray3)
                .offset(x: 65, y: 29)

            WidgetMenuList(menus: menusForCafeteria, maxWidth: 119)
                .offset(x: 17, y: 55)

            BobmooLabel(status: status(for: selectedCafeteriaInfo.hours))
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

    private func status(for hours: String) -> OperationStatus {
        guard let period = hours.bobmooOperationPeriod(on: entry.date) else { return .ended }
        return OperationStatusResolver.resolve(now: .now, period: period)
    }
}

// MARK: - ios_widget_2 (Medium)

private struct IosWidget2View: View {
    let entry: DietEntry

    var body: some View {
        ZStack(alignment: .topLeading) {
            BobmooText(dateText, style: .widget_sb_7)
                .foregroundStyle(.bobmooGray3)
                .offset(x: 19, y: 12)

            BobmooText(entry.mealTime, style: .widget_sb_14)
                .foregroundStyle(.bobmooBlack)
                .offset(x: 19, y: 30)

            BobmooText(hoursText, style: .widget_sb_7)
                .foregroundStyle(.bobmooGray3)
                .offset(x: 48, y: 31)

            WidgetCafeteriaColumn(info: cafeteria(for: "학생식당"))
                .offset(x: 20, y: 56)

            WidgetCafeteriaColumn(info: cafeteria(for: "교직원식당"))
                .offset(x: 126, y: 56)

            WidgetCafeteriaColumn(info: cafeteria(for: "생활관식당"))
                .offset(x: 228, y: 56)

            BobmooLabel(status: status(for: hoursText))
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

    private func status(for hours: String) -> OperationStatus {
        guard let period = hours.bobmooOperationPeriod(on: entry.date) else { return .ended }
        return OperationStatusResolver.resolve(now: .now, period: period)
    }
}

private struct WidgetCafeteriaColumn: View {
    let info: CafeteriaInfo

    var body: some View {
        ZStack(alignment: .topLeading) {
            BobmooText(info.name, style: .widget_sb_12)
                .foregroundStyle(.bobmooBlack)

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
                .fill(.bobmooGray5)
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
            BobmooText(item.course, style: .widget_m_11)
                .foregroundStyle(.bobmooBlack)
                .frame(width: 8, alignment: .leading)

            if item.course == "B" {
                BobmooText(item.menu, style: .widget_r_11_tight)
                    .foregroundStyle(.bobmooBlack)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.leading, 4)
                    .padding(.top, 3)
            } else {
                BobmooText(item.menu, style: .widget_r_11)
                    .foregroundStyle(.bobmooBlack)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.leading, 5)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
