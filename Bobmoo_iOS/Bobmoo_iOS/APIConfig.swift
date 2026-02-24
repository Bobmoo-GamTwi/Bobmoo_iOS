//
//  APIConfig.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/25/26.
//

import Foundation

enum APIConfig {
    static var baseURL: URL {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String,
              let url = URL(string: raw) else {
            preconditionFailure("Missing or invalid BASE_URL in Info.plist")
        }
        return url
    }
}
