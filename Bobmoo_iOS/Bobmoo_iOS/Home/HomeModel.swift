//
//  HomeModel.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/18/26.
//

import Foundation

struct DailyMenuResponse: Decodable, Sendable {
    let date: String
    let school: String
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
