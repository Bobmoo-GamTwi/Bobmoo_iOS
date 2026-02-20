//
//  HomeViewModel.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/18/26.
//

import Foundation
import SwiftUI
import Observation

@MainActor
@Observable
final class HomeViewModel {
    private let service: HomeMenuService

    enum MealSection: CaseIterable, Hashable {
        case breakfast
        case lunch
        case dinner
    }

    var selectedDate: Date = Date()

    var univName: String {
        menu?.school ?? "로딩중"
    }

    var univColor: String = "005BAC"
     
    var menu: DailyMenuResponse?
    var isLoading = false
    var errorMessage: String?

    var isEmptyMenu: Bool {
        !isLoading
        && errorMessage == nil
        && (menu?.cafeterias.isEmpty ?? false)
    }
    
    init(service: HomeMenuService) {
        self.service = service
    }

    func mealSectionOrder(now: Date) -> [MealSection] {
        let cafeterias = menu?.cafeterias ?? []

        let breakfastEnded = isMealEnded(now: now, cafeterias: cafeterias, hoursKeyPath: \.breakfast)
        let lunchEnded = isMealEnded(now: now, cafeterias: cafeterias, hoursKeyPath: \.lunch)
        let dinnerEnded = isMealEnded(now: now, cafeterias: cafeterias, hoursKeyPath: \.dinner)

        let first: MealSection
        if !breakfastEnded {
            first = .breakfast
        } else if !lunchEnded {
            first = .lunch
        } else if !dinnerEnded {
            first = .dinner
        } else {
            first = .breakfast
        }

        let all = MealSection.allCases
        guard let startIndex = all.firstIndex(of: first) else { return all }
        return Array(all[startIndex...]) + Array(all[..<startIndex])
    }

    private func isMealEnded(
        now: Date,
        cafeterias: [Cafeteria],
        hoursKeyPath: KeyPath<Hours, String>
    ) -> Bool {
        let endAtList = cafeterias.compactMap { cafeteria in
            cafeteria.hours[keyPath: hoursKeyPath].bobmooOperationPeriod(on: now)?.endAt
        }
        guard let latestEndAt = endAtList.max() else {
            return true
        }

        return now > latestEndAt
    }
     
    func load() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let fetchedMenu = try await service.fetchDailyMenu(date: selectedDate, school: "인하대학교")
            withAnimation(.easeInOut(duration: 0.25)) {
                menu = fetchedMenu
            }
        } catch {
            withAnimation(.easeInOut(duration: 0.25)) {
                errorMessage = String(describing: error)
            }
        }
    }

    var isCalendarPresented: Bool = false
    
    func didTapCalendar() {
        isCalendarPresented.toggle()
    }
}

extension HomeViewModel.MealSection {
    var title: String {
        switch self {
        case .breakfast:
            return "아침"
        case .lunch:
            return "점심"
        case .dinner:
            return "저녁"
        }
    }

    var hoursKeyPath: KeyPath<Hours, String> {
        switch self {
        case .breakfast:
            return \.breakfast
        case .lunch:
            return \.lunch
        case .dinner:
            return \.dinner
        }
    }

    var mealsKeyPath: KeyPath<Meals, [MealItem]?> {
        switch self {
        case .breakfast:
            return \.breakfast
        case .lunch:
            return \.lunch
        case .dinner:
            return \.dinner
        }
    }
}
