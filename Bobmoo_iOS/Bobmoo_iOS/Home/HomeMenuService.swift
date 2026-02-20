//
//  HomeMenuService.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/18/26.
//

import Foundation

protocol HomeMenuService {
    func fetchDailyMenu(date: Date, school: String) async throws -> DailyMenuResponse
}
