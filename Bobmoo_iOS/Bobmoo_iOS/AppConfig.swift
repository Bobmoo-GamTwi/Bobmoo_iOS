//
//  AppConfig.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/21/26.
//

import Foundation

enum AppConfig {
    static var baseURL: URL {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String,
              let url = URL(string: raw) else {
            preconditionFailure("Missing or invalid BASE_URL in Info.plist")
        }
        return url
    }

    private static let selectedSchoolKey = "selectedSchool"
    private static let selectedSchoolColorKey = "selectedSchoolColor"
    private static let defaultSchoolColor = "005BAC"

    static var selectedSchool: String? {
        get {
            UserDefaults.standard.string(forKey: selectedSchoolKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: selectedSchoolKey)
        }
    }

    static var selectedSchoolColor: String {
        get {
            UserDefaults.standard.string(forKey: selectedSchoolColorKey) ?? defaultSchoolColor
        }
        set {
            UserDefaults.standard.set(newValue, forKey: selectedSchoolColorKey)
        }
    }

    private static let selectedCafeteriaKey = "selectedCafeteria"
    private static let defaultCafeteria = "학생식당"

    static var selectedCafeteria: String {
        get {
            UserDefaults.standard.string(forKey: selectedCafeteriaKey) ?? defaultCafeteria
        }
        set {
            UserDefaults.standard.set(newValue, forKey: selectedCafeteriaKey)
        }
    }
}
