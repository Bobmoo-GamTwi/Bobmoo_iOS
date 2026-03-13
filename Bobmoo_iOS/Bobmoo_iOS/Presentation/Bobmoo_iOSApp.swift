//
//  Bobmoo_iOSApp.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/13/26.
//

import SwiftUI
import FirebaseCore
import FirebaseAnalytics

@main
struct Bobmoo_iOSApp: App {
    @State private var settings = AppSettings()

    init() {
        FirebaseApp.configure()
        Analytics.logEvent("debug_test", parameters: [
            "source": "app_launch"
        ])
    }

    var body: some Scene {
        WindowGroup {
            RootView(settings: settings)
                .environment(settings)
        }
    }
}
