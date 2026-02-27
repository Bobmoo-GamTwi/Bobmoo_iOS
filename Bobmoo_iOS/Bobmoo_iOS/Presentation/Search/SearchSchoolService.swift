//
//  SearchSchoolService.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/23/26.
//

import Foundation
import Alamofire

protocol SearchSchoolService {
    func fetchSchools(schoolQuery: String) async throws -> SchoolsResponse
}

struct SearchAPISchoolService: SearchSchoolService {
    enum ServiceError: Error {
        case invalidURL
    }

    func fetchSchools(schoolQuery: String) async throws -> SchoolsResponse {
        let url = try buildURL(schoolQuery: schoolQuery)

        let data = try await Session.default
            .request(url, method: .get)
            .validate(statusCode: 200..<300)
            .serializingData()
            .value

        return try JSONDecoder().decode(SchoolsResponse.self, from: data)
    }

    private func buildURL(schoolQuery: String) throws -> URL {
        var components = URLComponents(url: APIConfig.baseURL, resolvingAgainstBaseURL: false)
        let basePath = components?.path ?? ""
        components?.path = basePath + "/schools"
        components?.queryItems = [
            URLQueryItem(name: "school", value: schoolQuery)
        ]

        guard let url = components?.url else {
            throw ServiceError.invalidURL
        }
        return url
    }
}