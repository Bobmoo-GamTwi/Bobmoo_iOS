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

    // MARK: - Paging (3-page 무한 스와이프)

    var currentDate: Date = Calendar.current.startOfDay(for: Date()) {
        didSet {
            guard !Calendar.current.isDate(currentDate, inSameDayAs: oldValue) else { return }
            isCalendarPresented = false
            Task {
                let base = Calendar.current.startOfDay(for: currentDate)
                let prev = Calendar.current.date(byAdding: .day, value: -1, to: base)!
                let next = Calendar.current.date(byAdding: .day, value: 1, to: base)!
                await loadIfNeeded(date: base)
                await loadIfNeeded(date: prev)
                await loadIfNeeded(date: next)
            }
        }
    }

    var selectedTab: Int = 1

    func dateForTab(_ tab: Int) -> Date {
        let base = Calendar.current.startOfDay(for: currentDate)
        return Calendar.current.date(byAdding: .day, value: tab - 1, to: base)!
    }

    func handleTabChange(_ newTab: Int) {
        guard newTab != 1 else { return }

        let offset = newTab - 1
        let base = Calendar.current.startOfDay(for: currentDate)
        selectedTab = 1
        currentDate = Calendar.current.date(byAdding: .day, value: offset, to: base)!
    }

    // MARK: - Data

    var menuCache: [String: DailyMenuResponse] = [:]
    private var loadingDates: Set<String> = []
    var errorMessage: String?

    var univName: String {
        menuCache.values.first?.school ?? "로딩중"
    }

    var univColor: String = "005BAC"

    func dateKey(_ date: Date) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!)
    }

    func menu(for date: Date) -> DailyMenuResponse? {
        menuCache[dateKey(date)]
    }

    func hasMenu(for date: Date) -> Bool {
        menuCache[dateKey(date)] != nil
    }

    func isEmptyMenu(for date: Date) -> Bool {
        guard let cached = menuCache[dateKey(date)] else { return false }
        return cached.cafeterias.isEmpty
    }

    var isPreloaded: Bool {
        !menuCache.isEmpty
    }

    // MARK: - Init

    init(service: HomeMenuService) {
        self.service = service
    }

    // MARK: - Loading

    func preload() async {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = cal.date(byAdding: .day, value: 1, to: today)!

        await loadIfNeeded(date: today)
        await loadIfNeeded(date: yesterday)
        await loadIfNeeded(date: tomorrow)
    }

    func loadIfNeeded(date: Date) async {
        let key = dateKey(date)
        guard menuCache[key] == nil, !loadingDates.contains(key) else { return }

        loadingDates.insert(key)
        defer { loadingDates.remove(key) }

        do {
            let result = try await service.fetchDailyMenu(date: date, school: AppConfig.selectedSchool)
            withAnimation(.easeInOut(duration: 0.25)) {
                menuCache[key] = result
            }
        } catch {
            print("[HomeViewModel] loadIfNeeded(\(key)) failed: \(error)")
        }
    }

    func reloadDate(_ date: Date) async {
        let key = dateKey(date)
        loadingDates.insert(key)
        defer { loadingDates.remove(key) }

        do {
            let result = try await service.fetchDailyMenu(date: date, school: AppConfig.selectedSchool)
            withAnimation(.easeInOut(duration: 0.25)) {
                menuCache[key] = result
            }
        } catch {
            print("[HomeViewModel] reloadDate(\(key)) failed: \(error)")
        }
    }

    // MARK: - Calendar

    var isCalendarPresented: Bool = false

    func didTapCalendar() {
        isCalendarPresented.toggle()
    }

    // MARK: - Meal ordering

    func mealSectionOrder(now: Date, cafeterias: [Cafeteria]) -> [MealSection] {
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
