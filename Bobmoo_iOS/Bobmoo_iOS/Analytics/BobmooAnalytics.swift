import Foundation
import FirebaseAnalytics
import AmplitudeSwift

enum BobmooScreen: String {
    case splash
    case onboarding
    case search
    case home
    case setting
}

struct AnalyticsEvent {
    let name: String
    let properties: [String: Any]

    init(name: String, properties: [String: Any?] = [:]) {
        self.name = name
        self.properties = properties.compactMapValues { $0 }
    }
}

protocol AnalyticsClient {
    func track(event: AnalyticsEvent)
    func setUserProperties(_ properties: [String: Any?])
    func setUserId(_ id: String?)
    func reset()
}

struct AnalyticsConfiguration {
    let environment: String
    let amplitudeAPIKey: String?

    static func fromBundle(_ bundle: Bundle = .main) -> AnalyticsConfiguration {
        let environment = (bundle.object(forInfoDictionaryKey: "ANALYTICS_ENVIRONMENT") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nonEmpty ?? defaultEnvironment

        let amplitudeAPIKey = (bundle.object(forInfoDictionaryKey: "AMPLITUDE_API_KEY") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nonEmpty

        return AnalyticsConfiguration(
            environment: environment,
            amplitudeAPIKey: amplitudeAPIKey
        )
    }

    private static var defaultEnvironment: String {
#if DEBUG
        "debug"
#else
        "release"
#endif
    }
}

final class FirebaseAnalyticsClient: AnalyticsClient {
    func track(event: AnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.properties)
    }

    func setUserProperties(_ properties: [String: Any?]) {
        properties.forEach { key, value in
            Analytics.setUserProperty(firebaseUserPropertyValue(from: value), forName: key)
        }
    }

    func setUserId(_ id: String?) {
        Analytics.setUserID(id)
    }

    func reset() {
        Analytics.resetAnalyticsData()
    }
}

final class AmplitudeAnalyticsClient: AnalyticsClient {
    private let amplitude: Amplitude

    init(apiKey: String) {
        let configuration = Configuration(
            apiKey: apiKey,
            flushQueueSize: 30,
            flushIntervalMillis: 10_000,
            autocapture: .sessions
        )
        amplitude = Amplitude(configuration: configuration)
    }

    func track(event: AnalyticsEvent) {
        amplitude.track(eventType: event.name, eventProperties: event.properties)
    }

    func setUserProperties(_ properties: [String: Any?]) {
        let identify = Identify()

        properties.forEach { key, value in
            applyIdentifyValue(identify, key: key, value: value)
        }

        amplitude.identify(identify: identify)
    }

    func setUserId(_ id: String?) {
        amplitude.setUserId(userId: id)
    }

    func reset() {
        amplitude.reset()
    }
}

final class CompositeAnalyticsClient: AnalyticsClient {
    private let clients: [AnalyticsClient]

    init(clients: [AnalyticsClient]) {
        self.clients = clients
    }

    func track(event: AnalyticsEvent) {
        debugLog("track", payload: [
            "event": event.name,
            "properties": event.properties
        ])

        clients.forEach { $0.track(event: event) }
    }

    func setUserProperties(_ properties: [String: Any?]) {
        debugLog("user_properties", payload: properties.compactMapValues { $0 })
        clients.forEach { $0.setUserProperties(properties) }
    }

    func setUserId(_ id: String?) {
        debugLog("user_id", payload: ["user_id": id as Any])
        clients.forEach { $0.setUserId(id) }
    }

    func reset() {
        debugLog("reset", payload: [:])
        clients.forEach { $0.reset() }
    }

    private func debugLog(_ action: String, payload: [String: Any]) {
#if DEBUG
        print("[Analytics][\(action)] \(payload)")
#endif
    }
}

private final class NoOpAnalyticsClient: AnalyticsClient {
    func track(event: AnalyticsEvent) {}
    func setUserProperties(_ properties: [String: Any?]) {}
    func setUserId(_ id: String?) {}
    func reset() {}
}

final class BobmooAnalytics {
    static let shared = BobmooAnalytics()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private var client: AnalyticsClient = NoOpAnalyticsClient()
    private weak var settings: AppSettings?
    private var environment: String = AnalyticsConfiguration.fromBundle().environment

    private init() {}

    func configure(client: AnalyticsClient, settings: AppSettings, environment: String) {
        self.client = client
        self.settings = settings
        self.environment = environment
        refreshUserProperties()
    }

    func logSplashViewed(entryPoint: String? = nil, routeSource: String? = nil) {
        trackViewEvent("splash_viewed", entryPoint: entryPoint, routeSource: routeSource)
    }

    func logOnboardingViewed(entryPoint: String? = nil, routeSource: String? = nil) {
        trackViewEvent("onboarding_viewed", entryPoint: entryPoint, routeSource: routeSource)
    }

    func logSearchViewed(entryPoint: String? = nil, routeSource: String? = nil) {
        trackViewEvent("search_viewed", entryPoint: entryPoint, routeSource: routeSource)
    }

    func logHomeViewed(date: Date, entryPoint: String? = nil, routeSource: String? = nil) {
        trackViewEvent(
            "home_viewed",
            properties: [
                "selected_date": Self.dateFormatter.string(from: date)
            ],
            entryPoint: entryPoint,
            routeSource: routeSource
        )
    }

    func logSettingsViewed(source: String, entryPoint: String? = nil, routeSource: String? = nil) {
        trackViewEvent(
            "settings_viewed",
            properties: [
                "source": source
            ],
            entryPoint: entryPoint,
            routeSource: routeSource
        )
    }

    func logAppOpened() {
        refreshUserProperties()
        track("app_opened", includeSchoolContext: true)
    }

    func logOnboardingStarted() {
        track("onboarding_started", includeSchoolContext: true)
    }

    func logSchoolDirectoryLoaded(count: Int) {
        track("school_directory_loaded", properties: [
            "school_count": count
        ])
    }

    func logSchoolSearchPerformed(queryLength: Int, resultCount: Int, isEmptyQuery: Bool) {
        track("school_search_performed", properties: [
            "query_length": queryLength,
            "result_count": resultCount,
            "is_empty_query": isEmptyQuery
        ])
    }

    func logSchoolSelected(id: Int, name: String) {
        track("school_selected", properties: [
            "selected_school_id": id,
            "selected_school_name": name
        ], includeSchoolContext: true)
    }

    func logSchoolSelectionCompleted(selectedSchoolId: Int?, schoolName: String?) {
        track("school_selection_completed", properties: [
            "selected_school_id": selectedSchoolId,
            "selected_school_name": schoolName
        ], includeSchoolContext: true)
    }

    func logHomeDateSwiped(direction: String, fromDate: Date, toDate: Date) {
        track("home_date_swiped", properties: [
            "direction": direction,
            "from_date": Self.dateFormatter.string(from: fromDate),
            "to_date": Self.dateFormatter.string(from: toDate)
        ], includeSchoolContext: true)
    }

    func logCalendarOpened(date: Date) {
        track("calendar_opened", properties: [
            "selected_date": Self.dateFormatter.string(from: date)
        ], includeSchoolContext: true)
    }

    func logCalendarDateSelected(previousDate: Date, selectedDate: Date) {
        track("calendar_date_selected", properties: [
            "previous_date": Self.dateFormatter.string(from: previousDate),
            "selected_date": Self.dateFormatter.string(from: selectedDate)
        ], includeSchoolContext: true)
    }

    func logMenuViewed(date: Date, cafeteriaCount: Int, source: String) {
        track("menu_viewed", properties: [
            "selected_date": Self.dateFormatter.string(from: date),
            "cafeteria_count": cafeteriaCount,
            "source": source
        ], includeSchoolContext: true)
    }

    func logMenuReloadRequested(date: Date, source: String) {
        track("menu_reload_requested", properties: [
            "selected_date": Self.dateFormatter.string(from: date),
            "source": source
        ], includeSchoolContext: true)
    }

    func logMenuLoadSucceeded(date: Date, cafeteriaCount: Int, source: String) {
        track("menu_load_succeeded", properties: [
            "selected_date": Self.dateFormatter.string(from: date),
            "cafeteria_count": cafeteriaCount,
            "source": source
        ], includeSchoolContext: true)
    }

    func logMenuLoadFailed(date: Date, source: String, error: Error) {
        let errorInfo = normalizedErrorInfo(from: error)
        track("menu_load_failed", properties: [
            "selected_date": Self.dateFormatter.string(from: date),
            "source": source,
            "error_domain": errorInfo.domain,
            "error_code": errorInfo.code,
            "error_message_sanitized": errorInfo.message
        ], includeSchoolContext: true)
    }

    func logSchoolSettingTapped() {
        track("school_setting_tapped", includeSchoolContext: true)
    }

    func logWidgetCafeteriaChanged(previous: String, current: String) {
        track("widget_cafeteria_changed", properties: [
            "previous_cafeteria": previous,
            "widget_default_cafeteria": current
        ], includeSchoolContext: true)
    }

    func logUpdatePromptViewed() {
        track("update_prompt_viewed", includeSchoolContext: true)
    }

    func logUpdatePromptClicked(action: String) {
        track("update_prompt_clicked", properties: [
            "action": action
        ], includeSchoolContext: true)
    }

    func logDeepLinkOpened(destination: String) {
        track("deep_link_opened", properties: [
            "destination": destination
        ], includeSchoolContext: true)
    }

    func refreshUserProperties() {
        let hasSelectedSchool = settings?.hasSelectedSchool ?? false
        let properties: [String: Any?] = [
            "selected_school_id": settings?.selectedSchoolId,
            "selected_school_name": settings?.selectedSchool,
            "selected_school_color": hasSelectedSchool ? settings?.selectedSchoolColor : nil,
            "has_selected_school": hasSelectedSchool,
            "widget_default_cafeteria": settings?.selectedCafeteria
        ]
        client.setUserProperties(properties)
    }

    func setUserId(_ id: String?) {
        client.setUserId(id)
    }

    func reset() {
        client.reset()
    }

    private func track(
        _ name: String,
        properties: [String: Any?] = [:],
        includeSchoolContext: Bool = false
    ) {
        var payload = commonProperties()
        payload.merge(properties) { _, new in new }

        if includeSchoolContext {
            payload.merge(schoolContextProperties()) { _, new in new }
        }

        client.track(event: AnalyticsEvent(name: name, properties: payload))
    }

    private func trackViewEvent(
        _ name: String,
        properties: [String: Any?] = [:],
        entryPoint: String? = nil,
        routeSource: String? = nil
    ) {
        var payload = properties
        payload["entry_point"] = entryPoint
        payload["route_source"] = routeSource
        track(name, properties: payload, includeSchoolContext: true)
    }

    private func commonProperties() -> [String: Any?] {
        [
            "platform": "iOS",
            "app_version": Bundle.main.appVersion,
            "build_number": Bundle.main.buildNumber,
            "environment": environment,
            "has_selected_school": settings?.hasSelectedSchool ?? false
        ]
    }

    private func schoolContextProperties() -> [String: Any?] {
        [
            "selected_school_id": settings?.selectedSchoolId,
            "selected_school_name": settings?.selectedSchool
        ]
    }
}

private struct AnalyticsErrorInfo {
    let domain: String
    let code: Int
    let message: String
}

private func normalizedErrorInfo(from error: Error) -> AnalyticsErrorInfo {
    let nsError = error as NSError
    return AnalyticsErrorInfo(
        domain: nsError.domain,
        code: nsError.code,
        message: sanitizedErrorMessage(nsError.localizedDescription)
    )
}

private func sanitizedErrorMessage(_ message: String) -> String {
    let collapsed = message
        .replacingOccurrences(of: "\n", with: " ")
        .replacingOccurrences(of: "\r", with: " ")
        .replacingOccurrences(of: "\t", with: " ")
        .components(separatedBy: .whitespaces)
        .filter { !$0.isEmpty }
        .joined(separator: " ")

    return String(collapsed.prefix(120))
}

private func firebaseUserPropertyValue(from value: Any?) -> String? {
    switch value {
    case nil:
        return nil
    case let value as String:
        return value
    case let value as Bool:
        return value ? "true" : "false"
    case let value as Int:
        return String(value)
    case let value as Int64:
        return String(value)
    case let value as Double:
        return String(value)
    case let value as Float:
        return String(value)
    default:
        return String(describing: value)
    }
}

private func applyIdentifyValue(_ identify: Identify, key: String, value: Any?) {
    switch value {
    case nil:
        identify.unset(property: key)
    case let value as Bool:
        identify.set(property: key, value: value)
    case let value as Int:
        identify.set(property: key, value: value)
    case let value as Int64:
        identify.set(property: key, value: value)
    case let value as Double:
        identify.set(property: key, value: value)
    case let value as Float:
        identify.set(property: key, value: value)
    case let value as String:
        identify.set(property: key, value: value)
    case let value as [String: Any]:
        identify.set(property: key, value: value)
    case let value as [Any]:
        identify.set(property: key, value: value)
    default:
        identify.set(property: key, value: String(describing: value))
    }
}

private extension Bundle {
    var appVersion: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
    }

    var buildNumber: String {
        object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? "unknown"
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
