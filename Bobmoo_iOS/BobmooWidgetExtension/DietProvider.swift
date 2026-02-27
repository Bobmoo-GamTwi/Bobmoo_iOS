import Foundation
import WidgetKit

struct DietProvider: TimelineProvider {
    func placeholder(in context: Context) -> DietEntry {
        sampleEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (DietEntry) -> Void) {
        if context.isPreview {
            completion(sampleEntry(date: .now))
            return
        }

        Task {
            completion(await fetchEntryOrFallback(date: .now))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DietEntry>) -> Void) {
        let now = Date()
        let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 2, to: now)
            ?? now.addingTimeInterval(2 * 60 * 60)

        Task {
            let entry = await fetchEntryOrFallback(date: now)
            completion(Timeline(entries: [entry], policy: .after(nextUpdateDate)))
        }
    }

    private func fetchEntryOrFallback(date: Date) async -> DietEntry {
        let school = UserDefaults.bobmooShared.string(forKey: "selectedSchool") ?? "인하대학교"

        do {
            return try await DietAPIService.fetchDietData(date: date, school: school)
        } catch {
            return fallbackEntry(date: date)
        }
    }

    private func sampleEntry(date: Date) -> DietEntry {
        DietEntry(
            date: date,
            mealTime: "아침",
            cafeterias: [
                CafeteriaInfo(
                    name: "학생식당",
                    hours: "08:00-09:30",
                    menus: ["A: 돈가스*소스", "B: 어묵볶음, 김치콩나물국", "C: 요구르트"]
                ),
                CafeteriaInfo(
                    name: "교직원식당",
                    hours: "08:00-09:30",
                    menus: ["A: 돈가스*소스", "B: 어묵볶음, 김치콩나물국", "C: 요구르트"]
                ),
                CafeteriaInfo(
                    name: "생활관식당",
                    hours: "08:00-09:30",
                    menus: ["A: 돈가스*소스", "B: 어묵볶음, 김치콩나물국", "C: 요구르트"]
                )
            ]
        )
    }

    private func fallbackEntry(date: Date) -> DietEntry {
        DietEntry(
            date: date,
            mealTime: "점심",
            cafeterias: [
                CafeteriaInfo(
                    name: "학식 정보",
                    hours: "미운영",
                    menus: ["미운영"]
                )
            ]
        )
    }
}
