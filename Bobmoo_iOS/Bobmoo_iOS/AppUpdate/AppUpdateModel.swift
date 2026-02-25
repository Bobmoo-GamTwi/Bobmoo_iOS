//
//  AppUpdateModel.swift
//  Bobmoo_iOS
//
//  Created by Antigravity on 2/25/26.
//

import Foundation

struct iTunesLookupResponse: Codable {
    let resultCount: Int
    let results: [iTunesAppInfo]
}

struct iTunesAppInfo: Codable {
    let trackId: Int
    let version: String
    let trackViewUrl: String
}
