import Foundation

extension String {
    func bobmooOperationPeriod(on day: Date, calendar: Calendar = .current) -> OperationPeriod? {
        guard !contains("미운영") else { return nil }

        let delimiters = CharacterSet(charactersIn: "-~")
        let parts = components(separatedBy: delimiters)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard parts.count == 2,
              let startAt = calendar.bobmooDate(on: day, timeText: parts[0]),
              let endAt = calendar.bobmooDate(on: day, timeText: parts[1]) else {
            return nil
        }

        return OperationPeriod(startAt: startAt, endAt: endAt)
    }
}

private extension Calendar {
    func bobmooDate(on day: Date, timeText: String) -> Date? {
        let parts = timeText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: ":")
            .compactMap { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }

        guard parts.count == 2 else { return nil }
        return date(bySettingHour: parts[0], minute: parts[1], second: 0, of: day)
    }
}
