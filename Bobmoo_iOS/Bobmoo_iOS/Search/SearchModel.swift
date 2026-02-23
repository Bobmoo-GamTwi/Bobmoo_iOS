//
//  SearchModel.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/23/26.
//

import Foundation

struct SchoolsResponse: Decodable, Sendable {
    let status: String
    let data: [School]
}

struct School: Decodable, Sendable, Identifiable {
    let schoolId: Int
    let schoolName: String
    let schoolColor: String

    var id: Int { schoolId }
}
