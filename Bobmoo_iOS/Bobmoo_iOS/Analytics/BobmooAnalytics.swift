import Foundation
import FirebaseAnalytics

enum BobmooScreen: String {
    case splash
    case onboarding
    case search
    case home
    case setting
}

final class BobmooAnalytics {
    static let shared = BobmooAnalytics()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private init() {}

    func logScreenView(_ screen: BobmooScreen, entryPoint: String? = nil) {
        var parameters: [String: Any] = [
            AnalyticsParameterScreenName: screen.rawValue,
            AnalyticsParameterScreenClass: "SwiftUI"
        ]

        if let entryPoint {
            parameters["entry_point"] = entryPoint
        }

        Analytics.logEvent(AnalyticsEventScreenView, parameters: parameters)
    }

    func logAppOpen(hasSelectedSchool: Bool) {
        log("app_open", [
            "has_selected_school": hasSelectedSchool
        ])
    }

    func logOnboardingStarted(hasSelectedSchool: Bool) {
        log("onboarding_started", [
            "has_selected_school": hasSelectedSchool
        ])
    }

    func logSearchResultsLoaded(count: Int) {
        log("school_directory_loaded", [
            "school_count": count
        ])
    }

    func logSearch(queryLength: Int, resultCount: Int, isEmptyQuery: Bool) {
        log("school_search", [
            "query_length": queryLength,
            "result_count": resultCount,
            "is_empty_query": isEmptyQuery
        ])
    }

    func logSchoolSelected(id: Int, name: String) {
        log("school_selected", [
            "school_id": id,
            "school_name": name
        ])
    }

    func logSchoolSelectionCompleted(selectedSchoolId: Int?, schoolName: String?) {
        log("school_selection_completed", [
            "has_selected_school": selectedSchoolId != nil,
            "school_id": selectedSchoolId,
            "school_name": schoolName
        ])
    }

    func logHomeOpened(schoolName: String?, date: Date) {
        log("home_opened", [
            "school_name": schoolName,
            "selected_date": Self.dateFormatter.string(from: date)
        ])
    }

    func logDateSwiped(direction: String, fromDate: Date, toDate: Date) {
        log("home_date_swiped", [
            "direction": direction,
            "from_date": Self.dateFormatter.string(from: fromDate),
            "to_date": Self.dateFormatter.string(from: toDate)
        ])
    }

    func logCalendarOpened(date: Date) {
        log("calendar_opened", [
            "selected_date": Self.dateFormatter.string(from: date)
        ])
    }

    func logCalendarDateSelected(previousDate: Date, selectedDate: Date) {
        log("calendar_date_selected", [
            "previous_date": Self.dateFormatter.string(from: previousDate),
            "selected_date": Self.dateFormatter.string(from: selectedDate)
        ])
    }

    func logMenuViewed(date: Date, schoolName: String?, cafeteriaCount: Int, source: String) {
        log("menu_day_viewed", [
            "selected_date": Self.dateFormatter.string(from: date),
            "school_name": schoolName,
            "cafeteria_count": cafeteriaCount,
            "source": source
        ])
    }

    func logMenuReload(date: Date, source: String) {
        log("menu_reloaded", [
            "selected_date": Self.dateFormatter.string(from: date),
            "source": source
        ])
    }

    func logMenuLoadSucceeded(date: Date, schoolName: String?, cafeteriaCount: Int, source: String) {
        log("menu_load_succeeded", [
            "selected_date": Self.dateFormatter.string(from: date),
            "school_name": schoolName,
            "cafeteria_count": cafeteriaCount,
            "source": source
        ])
    }

    func logMenuLoadFailed(date: Date, schoolName: String?, source: String, errorMessage: String) {
        log("menu_load_failed", [
            "selected_date": Self.dateFormatter.string(from: date),
            "school_name": schoolName,
            "source": source,
            "error_message": errorMessage
        ])
    }

    func logSettingsOpened(source: String, schoolName: String?) {
        log("settings_opened", [
            "source": source,
            "school_name": schoolName
        ])
    }

    func logSchoolSettingTapped(currentSchoolName: String?) {
        log("school_setting_tapped", [
            "current_school_name": currentSchoolName
        ])
    }

    func logWidgetCafeteriaChanged(previous: String, current: String) {
        log("widget_cafeteria_changed", [
            "previous_cafeteria": previous,
            "selected_cafeteria": current
        ])
    }

    func logUpdatePromptShown() {
        log("update_prompt_shown")
    }

    func logUpdatePromptAction(_ action: String) {
        log("update_prompt_action", [
            "action": action
        ])
    }

    func logDeepLinkOpened(destination: String, hasSelectedSchool: Bool) {
        log("deep_link_opened", [
            "destination": destination,
            "has_selected_school": hasSelectedSchool
        ])
    }

    private func log(_ name: String, _ parameters: [String: Any?] = [:]) {
        Analytics.logEvent(name, parameters: parameters.compactMapValues { $0 })
    }
}
