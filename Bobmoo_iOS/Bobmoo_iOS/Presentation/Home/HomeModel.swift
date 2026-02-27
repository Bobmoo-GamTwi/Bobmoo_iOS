//
//  HomeModel.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/18/26.
//

import Foundation

struct DailyMenuResponse: Decodable, Sendable {
    let date: String
    let schools: [SchoolMenu]

    private enum CodingKeys: String, CodingKey {
        case date
        case schools
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(String.self, forKey: .date)

        if let array = try? container.decode([SchoolMenu].self, forKey: .schools) {
            schools = array
        } else if let object = try? container.decode(SchoolMenu.self, forKey: .schools) {
            schools = [object]
        } else {
            schools = []
        }
    }
}

struct SchoolMenu: Decodable, Sendable {
    let schoolName: String
    let cafeterias: [Cafeteria]
}

struct Cafeteria: Decodable, Sendable {
    let name: String
    let hours: Hours
    let meals: Meals
}

struct Hours: Decodable, Sendable {
    let breakfast: String
    let lunch: String
    let dinner: String
}

struct Meals: Decodable, Sendable {
    let breakfast: [MealItem]?
    let lunch: [MealItem]?
    let dinner: [MealItem]?
}

struct MealItem: Decodable, Sendable {
    let course: String
    let mainMenu: String
    let price: Int
}
