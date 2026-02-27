//
//  AppSettings.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/21/26.
//

import Foundation
import Observation
import WidgetKit

@Observable
final class AppSettings {
    private static let selectedSchoolKey = "selectedSchool"
    private static let selectedSchoolColorKey = "selectedSchoolColor"
    private static let defaultSchoolColor = "005BAC"
    private static let selectedCafeteriaKey = "selectedCafeteria"
    private static let defaultCafeteria = "학생식당"
    private static let dietWidgetKind = "DietWidget"

    var selectedSchool: String? {
        didSet { Self.defaults.set(selectedSchool, forKey: Self.selectedSchoolKey) }
    }

    var selectedSchoolColor: String {
        didSet { Self.defaults.set(selectedSchoolColor, forKey: Self.selectedSchoolColorKey) }
    }

    var selectedCafeteria: String {
        didSet {
            Self.defaults.set(selectedCafeteria, forKey: Self.selectedCafeteriaKey)
            guard oldValue != selectedCafeteria else { return }
            WidgetCenter.shared.reloadTimelines(ofKind: Self.dietWidgetKind)
        }
    }

    init() {
        Self.migrateStandardToSharedIfNeeded()

        self.selectedSchool = Self.defaults.string(forKey: Self.selectedSchoolKey)
        self.selectedSchoolColor = Self.defaults.string(forKey: Self.selectedSchoolColorKey) ?? Self.defaultSchoolColor
        self.selectedCafeteria = Self.defaults.string(forKey: Self.selectedCafeteriaKey) ?? Self.defaultCafeteria
    }
}

private extension AppSettings {
    static var defaults: UserDefaults { .bobmooShared }

    static func migrateStandardToSharedIfNeeded() {
        let standard = UserDefaults.standard
        let shared = Self.defaults

        if shared.object(forKey: selectedSchoolKey) == nil, let value = standard.string(forKey: selectedSchoolKey) {
            shared.set(value, forKey: selectedSchoolKey)
        }

        if shared.object(forKey: selectedSchoolColorKey) == nil, let value = standard.string(forKey: selectedSchoolColorKey) {
            shared.set(value, forKey: selectedSchoolColorKey)
        }

        if shared.object(forKey: selectedCafeteriaKey) == nil, let value = standard.string(forKey: selectedCafeteriaKey) {
            shared.set(value, forKey: selectedCafeteriaKey)
        }
    }
}
