//
//  Bobmoo_iOSApp.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/13/26.
//

import SwiftUI

@main
struct Bobmoo_iOSApp: App {
    @State private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            RootView(settings: settings)
                .environment(settings)
        }
    }
}
