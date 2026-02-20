//
//  HomeMenuService.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/18/26.
//

import Foundation
import Alamofire

protocol HomeMenuService {
    func fetchDailyMenu(date: Date, school: String) async throws -> DailyMenuResponse
}

struct HomeAPIMenuService: HomeMenuService {
    enum ServiceError: Error {
        case invalidURL
    }

    func fetchDailyMenu(date: Date, school: String) async throws -> DailyMenuResponse {
        let url = try buildURL(date: date, school: school)

        let data = try await Session.default
            .request(url, method: .get)
            .validate(statusCode: 200..<300)
            .serializingData()
            .value

        return try JSONDecoder().decode(DailyMenuResponse.self, from: data)
    }

    private func buildURL(date: Date, school: String) throws -> URL {
        var components = URLComponents(url: AppConfig.baseURL, resolvingAgainstBaseURL: false)
        let basePath = components?.path ?? ""
        components?.path = basePath + "/menu"
        components?.queryItems = [
            URLQueryItem(name: "date", value: Self.dateFormatter.string(from: date)),
            URLQueryItem(name: "school", value: school)
        ]

        guard let url = components?.url else {
            throw ServiceError.invalidURL
        }
        return url
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
