//
//  AppSettings.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/21/26.
//

import Foundation
import Observation

@Observable
final class AppSettings {
    private static let selectedSchoolKey = "selectedSchool"
    private static let selectedSchoolColorKey = "selectedSchoolColor"
    private static let defaultSchoolColor = "005BAC"
    private static let selectedCafeteriaKey = "selectedCafeteria"
    private static let defaultCafeteria = "학생식당"

    var selectedSchool: String? {
        didSet { UserDefaults.standard.set(selectedSchool, forKey: Self.selectedSchoolKey) }
    }

    var selectedSchoolColor: String {
        didSet { UserDefaults.standard.set(selectedSchoolColor, forKey: Self.selectedSchoolColorKey) }
    }

    var selectedCafeteria: String {
        didSet { UserDefaults.standard.set(selectedCafeteria, forKey: Self.selectedCafeteriaKey) }
    }

    init() {
        self.selectedSchool = UserDefaults.standard.string(forKey: Self.selectedSchoolKey)
        self.selectedSchoolColor = UserDefaults.standard.string(forKey: Self.selectedSchoolColorKey) ?? Self.defaultSchoolColor
        self.selectedCafeteria = UserDefaults.standard.string(forKey: Self.selectedCafeteriaKey) ?? Self.defaultCafeteria
    }
}
