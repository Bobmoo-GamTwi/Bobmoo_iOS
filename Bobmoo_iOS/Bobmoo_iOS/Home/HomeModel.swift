//
//  HomeModel.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/18/26.
//

import Foundation

struct DailyMenuResponse: Decodable {
    let date: String
    let school: String
    let cafeterias: [Cafeteria]
}

struct Cafeteria: Decodable {
    let name: String
    let hours: Hours
    let meals: Meals
}

struct Hours: Decodable {
    let breakfast: String
    let lunch: String
    let dinner: String
}

struct Meals: Decodable {
    let breakfast: [MealItem]?
    let lunch: [MealItem]?
    let dinner: [MealItem]?
}

struct MealItem: Decodable {
    let course: String
    let mainMenu: String
    let price: Int
}
