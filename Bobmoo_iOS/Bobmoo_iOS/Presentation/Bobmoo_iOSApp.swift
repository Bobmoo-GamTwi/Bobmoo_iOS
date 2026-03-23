//
//  Bobmoo_iOSApp.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/13/26.
//

import SwiftUI
import FirebaseCore

@main
struct Bobmoo_iOSApp: App {
    @State private var settings: AppSettings

    init() {
        let appSettings = AppSettings()
        _settings = State(initialValue: appSettings)

        FirebaseApp.configure()

        let analyticsConfiguration = AnalyticsConfiguration.fromBundle()
        var clients: [AnalyticsClient] = [FirebaseAnalyticsClient()]

        if let amplitudeAPIKey = analyticsConfiguration.amplitudeAPIKey {
            clients.append(AmplitudeAnalyticsClient(apiKey: amplitudeAPIKey))
        } else {
#if DEBUG
            print("[Analytics] Missing AMPLITUDE_API_KEY. Firebase-only collection is active.")
#endif
        }

        BobmooAnalytics.shared.configure(
            client: CompositeAnalyticsClient(clients: clients),
            settings: appSettings,
            environment: analyticsConfiguration.environment
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView(settings: settings)
                .environment(settings)
        }
    }
}
