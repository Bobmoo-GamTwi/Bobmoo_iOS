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
    private static let defaultSchool = "inha"

    static var selectedSchool: String {
        get {
            UserDefaults.standard.string(forKey: selectedSchoolKey) ?? defaultSchool
        }
        set {
            UserDefaults.standard.set(newValue, forKey: selectedSchoolKey)
        }
    }
}
