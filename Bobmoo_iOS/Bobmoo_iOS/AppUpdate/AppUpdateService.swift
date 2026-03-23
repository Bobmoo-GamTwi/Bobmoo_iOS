//
//  AppUpdateService.swift
//  Bobmoo_iOS
//
//  Created by Antigravity on 2/25/26.
//

import Foundation
import Alamofire

// MARK: - Result

enum AppUpdateResult {
    case updateAvailable(storeURL: URL)
    case upToDate
    case failed
}

// MARK: - Protocol

protocol AppUpdateService {
    func checkForUpdate() async -> AppUpdateResult
}

// MARK: - API Implementation

struct AppUpdateAPIService: AppUpdateService {

    func checkForUpdate() async -> AppUpdateResult {
        guard let bundleId = Bundle.main.bundleIdentifier else { return .failed }

        let urlString = "https://itunes.apple.com/lookup?bundleId=\(bundleId)&country=kr"

        // Use serializingData() to avoid Sendable constraint on iTunesLookupResponse,
        // then decode manually — best-effort; any failure returns .failed.
        let dataTask = Session.default.request(urlString, method: .get).validate(statusCode: 200..<300).serializingData()

        do {
            let data = try await dataTask.value
            let lookupResponse = try JSONDecoder().decode(iTunesLookupResponse.self, from: data)

            guard let appInfo = lookupResponse.results.first else { return .failed }

            let currentVersion = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "0.0.0"

            guard isNewerVersion(storeVersion: appInfo.version, currentVersion: currentVersion) else {
                return .upToDate
            }

            let storeURL: URL
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appInfo.trackId)") {
                storeURL = url
            } else if let url = URL(string: appInfo.trackViewUrl) {
                storeURL = url
            } else {
                return .failed
            }

            return .updateAvailable(storeURL: storeURL)
        } catch {
            return .failed
        }
    }

    /// Returns `true` when `storeVersion` is strictly greater than `currentVersion`.
    /// Pads shorter version strings with zeros so "1.0" == "1.0.0" and "1.9.0" < "1.10.0".
    private func isNewerVersion(storeVersion: String, currentVersion: String) -> Bool {
        let store = storeVersion.split(separator: ".").compactMap { Int($0) }
        let current = currentVersion.split(separator: ".").compactMap { Int($0) }
        let length = max(store.count, current.count)

        for i in 0..<length {
            let s = i < store.count ? store[i] : 0
            let c = i < current.count ? current[i] : 0
            if s > c { return true }
            if s < c { return false }
        }
        return false
    }
}

// MARK: - Mock Implementation

struct AppUpdateMockService: AppUpdateService {

    let result: AppUpdateResult
    let delayNanoseconds: UInt64

    init(result: AppUpdateResult = .upToDate, delayNanoseconds: UInt64 = 0) {
        self.result = result
        self.delayNanoseconds = delayNanoseconds
    }

    func checkForUpdate() async -> AppUpdateResult {
        if delayNanoseconds > 0 {
            try? await Task.sleep(nanoseconds: delayNanoseconds)
        }
        return result
    }
}
