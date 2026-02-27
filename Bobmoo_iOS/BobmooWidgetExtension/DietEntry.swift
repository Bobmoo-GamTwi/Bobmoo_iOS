import WidgetKit

struct DietEntry: TimelineEntry, Sendable {
    let date: Date
    let mealTime: String
    let cafeterias: [CafeteriaInfo]
}

struct CafeteriaInfo: Sendable, Equatable {
    let name: String
    let hours: String
    let menus: [String]
}
