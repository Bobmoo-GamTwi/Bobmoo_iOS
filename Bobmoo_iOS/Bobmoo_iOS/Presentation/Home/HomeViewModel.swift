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
    private let settings: AppSettings
    private let analytics = BobmooAnalytics.shared

    enum MealSection: CaseIterable, Hashable {
        case breakfast
        case lunch
        case dinner
    }

    // MARK: - Paging (3-page 무한 스와이프)

    var currentDate: Date = Calendar.current.startOfDay(for: Date())

    var selectedTab: Int = 1

    func dateForTab(_ tab: Int) -> Date {
        let base = Calendar.current.startOfDay(for: currentDate)
        return Calendar.current.date(byAdding: .day, value: tab - 1, to: base)!
    }

    func handleTabChange(_ newTab: Int) {
        guard newTab != 1 else { return }

        let offset = newTab - 1
        let base = Calendar.current.startOfDay(for: currentDate)
        let updatedDate = Calendar.current.date(byAdding: .day, value: offset, to: base)!
        analytics.logHomeDateSwiped(
            direction: offset > 0 ? "next" : "previous",
            fromDate: base,
            toDate: updatedDate
        )
        selectedTab = 1
        currentDate = updatedDate
    }

    // MARK: - Data

    var menuCache: [String: DailyMenuResponse] = [:]
    private var loadingDates: Set<String> = []
    var errorMessage: String?

    var univName: String {
        if let schoolName = settings.selectedSchool, !schoolName.isEmpty {
            return schoolName
        }
        return menuCache.values.first?.schools.first?.schoolName ?? "로딩중"
    }

    var univColor: String { settings.selectedSchoolColor }

    func dateKey(_ date: Date) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!)
    }

    func cafeterias(for date: Date) -> [Cafeteria] {
        guard let menu = menuCache[dateKey(date)] else { return [] }
        let schoolMenu = menu.schools.first { $0.schoolName == settings.selectedSchool }
            ?? menu.schools.first
        return schoolMenu?.cafeterias ?? []
    }

    func hasMenu(for date: Date) -> Bool {
        menuCache[dateKey(date)] != nil
    }

    func isEmptyMenu(for date: Date) -> Bool {
        cafeterias(for: date).isEmpty
    }

    var isPreloaded: Bool {
        !menuCache.isEmpty
    }

    // MARK: - Init

    init(service: HomeMenuService, settings: AppSettings) {
        self.service = service
        self.settings = settings
    }

    // MARK: - Loading

    func preload() async {
        errorMessage = nil
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = cal.date(byAdding: .day, value: 1, to: today)!

        await loadIfNeeded(date: today)
        await loadIfNeeded(date: yesterday)
        await loadIfNeeded(date: tomorrow)
    }

    func loadIfNeeded(date: Date) async {
        await loadIfNeeded(date: date, source: "load_if_needed")
    }

    func loadIfNeeded(date: Date, source: String) async {
        let key = dateKey(date)
        guard menuCache[key] == nil, !loadingDates.contains(key) else { return }

        loadingDates.insert(key)
        defer { loadingDates.remove(key) }

        do {
            let result = try await service.fetchDailyMenu(date: date, school: settings.selectedSchool ?? "")
            withAnimation(.easeInOut(duration: 0.25)) {
                menuCache[key] = result
            }
            analytics.logMenuLoadSucceeded(
                date: date,
                cafeteriaCount: cafeterias(for: date).count,
                source: source
            )
        } catch {
            let school = settings.selectedSchool ?? ""
            if !school.isEmpty {
                errorMessage = error.localizedDescription
                analytics.logMenuLoadFailed(
                    date: date,
                    source: source,
                    error: error
                )
            }
            print("[HomeViewModel] loadIfNeeded(\(key)) failed: \(error)")
        }
    }

    func reloadDate(_ date: Date) async {
        await reloadDate(date, source: "pull_to_refresh")
    }

    func reloadDate(_ date: Date, source: String) async {
        let key = dateKey(date)
        loadingDates.insert(key)
        defer { loadingDates.remove(key) }

        analytics.logMenuReloadRequested(date: date, source: source)

        do {
            let result = try await service.fetchDailyMenu(date: date, school: settings.selectedSchool ?? "")
            withAnimation(.easeInOut(duration: 0.25)) {
                menuCache[key] = result
            }
            analytics.logMenuLoadSucceeded(
                date: date,
                cafeteriaCount: cafeterias(for: date).count,
                source: source
            )
        } catch {
            errorMessage = error.localizedDescription
            analytics.logMenuLoadFailed(
                date: date,
                source: source,
                error: error
            )
            print("[HomeViewModel] reloadDate(\(key)) failed: \(error)")
        }
    }

    // MARK: - Calendar

    var isCalendarPresented: Bool = false

    func didTapCalendar() {
        isCalendarPresented.toggle()
    }

    // MARK: - Reset

    func resetForSchoolChange() {
        menuCache.removeAll()
        currentDate = Calendar.current.startOfDay(for: Date())
        selectedTab = 1
        errorMessage = nil
        Task {
            await preload()
        }
    }

    // MARK: - Date Change

    func dateDidChange(from oldValue: Date, to newValue: Date) {
        if isCalendarPresented {
            analytics.logCalendarDateSelected(previousDate: oldValue, selectedDate: newValue)
        }

        analytics.logMenuViewed(
            date: newValue,
            cafeteriaCount: cafeterias(for: newValue).count,
            source: isCalendarPresented ? "calendar" : "date_change"
        )
        isCalendarPresented = false
    }

    func preloadAroundCurrentDate() async {
        let base = Calendar.current.startOfDay(for: currentDate)
        let prev = Calendar.current.date(byAdding: .day, value: -1, to: base)!
        let next = Calendar.current.date(byAdding: .day, value: 1, to: base)!
        await loadIfNeeded(date: base, source: "current_date")
        await loadIfNeeded(date: prev, source: "preload_previous")
        await loadIfNeeded(date: next, source: "preload_next")
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
