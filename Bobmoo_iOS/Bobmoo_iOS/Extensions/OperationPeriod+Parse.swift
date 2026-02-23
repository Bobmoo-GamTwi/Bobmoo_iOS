import Foundation

extension String {
    func bobmooOperationPeriod(on day: Date, calendar: Calendar = .current) -> OperationPeriod? {
        guard !contains("미운영") else { return nil }

        let parts = split(separator: "-").map { String($0) }

        guard let startAt = calendar.bobmooDate(on: day, timeText: parts[0]),
              let endAt = calendar.bobmooDate(on: day, timeText: parts[1]) else {
            return nil
        }

        return OperationPeriod(startAt: startAt, endAt: endAt)
    }
}

private extension Calendar {
    func bobmooDate(on day: Date, timeText: String) -> Date? {
        let parts = timeText.split(separator: ":").map { Int($0)! }
        return date(bySettingHour: parts[0], minute: parts[1], second: 0, of: day)
    }
}
