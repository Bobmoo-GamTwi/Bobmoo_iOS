import Foundation

enum DietAPIService {
    enum ServiceError: Error {
        case invalidURL
        case invalidResponse
    }

    static func fetchDietData(date: Date, school: String) async throws -> DietEntry {
        let url = try buildURL(date: date, school: school)
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw ServiceError.invalidResponse
        }

        let dailyMenu = try JSONDecoder().decode(DailyMenuResponse.self, from: data)
        return mapToDietEntry(dailyMenu, currentDate: date, school: school)
    }

    private static func buildURL(date: Date, school: String) throws -> URL {
        var components = URLComponents(url: APIConfig.baseURL, resolvingAgainstBaseURL: false)
        let basePath = components?.path ?? ""
        components?.path = basePath + "/menu"
        components?.queryItems = [
            URLQueryItem(name: "date", value: dateFormatter.string(from: date)),
            URLQueryItem(name: "school", value: school)
        ]

        guard let url = components?.url else {
            throw ServiceError.invalidURL
        }
        return url
    }

    private static func mapToDietEntry(_ response: DailyMenuResponse, currentDate: Date, school: String) -> DietEntry {
        // Select cafeterias for the target school (fallback to first school)
        let targetCafeterias = response.schools.first { $0.schoolName == school }?.cafeterias
            ?? response.schools.first?.cafeterias
            ?? []
        let mealTime = determineMealTime(from: targetCafeterias, currentDate: currentDate)
        let cafeteriaInfos: [CafeteriaInfo] = targetCafeterias.map { cafeteria in
            let hours: String
            let mealItems: [MealItem]?

            switch mealTime {
            case "아침":
                hours = cafeteria.hours.breakfast
                mealItems = cafeteria.meals.breakfast
            case "점심":
                hours = cafeteria.hours.lunch
                mealItems = cafeteria.meals.lunch
            case "저녁":
                hours = cafeteria.hours.dinner
                mealItems = cafeteria.meals.dinner
            default:
                hours = "미운영"
                mealItems = nil
            }

            let menus: [String]
            if let mealItems, !mealItems.isEmpty {
                menus = mealItems.map { "\($0.course): \($0.mainMenu)" }
            } else {
                menus = ["미운영"]
            }

            return CafeteriaInfo(name: cafeteria.name, hours: hours, menus: menus)
        }

        return DietEntry(date: currentDate, mealTime: mealTime, cafeterias: cafeteriaInfos)
    }

    private static func determineMealTime(from cafeterias: [Cafeteria], currentDate: Date) -> String {
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.hour, .minute], from: currentDate)
        let nowInMinutes = (currentComponents.hour ?? 0) * 60 + (currentComponents.minute ?? 0)

        struct MealRange {
            let label: String
            let startMinutes: Int
            let endMinutes: Int
        }

        var ranges: [MealRange] = []

        for cafeteria in cafeterias {
            if let breakfast = parseHours(cafeteria.hours.breakfast) {
                ranges.append(MealRange(label: "아침", startMinutes: breakfast.start, endMinutes: breakfast.end))
            }
            if let lunch = parseHours(cafeteria.hours.lunch) {
                ranges.append(MealRange(label: "점심", startMinutes: lunch.start, endMinutes: lunch.end))
            }
            if let dinner = parseHours(cafeteria.hours.dinner) {
                ranges.append(MealRange(label: "저녁", startMinutes: dinner.start, endMinutes: dinner.end))
            }
        }

        for range in ranges {
            if nowInMinutes >= range.startMinutes && nowInMinutes <= range.endMinutes {
                return range.label
            }
        }

        let upcoming = ranges.filter { $0.startMinutes > nowInMinutes }
            .sorted { $0.startMinutes < $1.startMinutes }

        if let firstUpcoming = upcoming.first {
            return firstUpcoming.label
        }

        return ranges.sorted { $0.endMinutes > $1.endMinutes }.first?.label ?? "점심"
    }

    private static func parseHours(_ hours: String) -> (start: Int, end: Int)? {
        guard !hours.contains("미운영") else { return nil }
        let delimiters = CharacterSet(charactersIn: "-~")
        let components = hours.components(separatedBy: delimiters)
        guard components.count == 2 else { return nil }

        let startPart = components[0].trimmingCharacters(in: .whitespaces).split(separator: ":")
        let endPart = components[1].trimmingCharacters(in: .whitespaces).split(separator: ":")

        guard startPart.count == 2, endPart.count == 2,
              let startH = Int(startPart[0]), let startM = Int(startPart[1]),
              let endH = Int(endPart[0]), let endM = Int(endPart[1]) else {
            return nil
        }

        return (start: startH * 60 + startM, end: endH * 60 + endM)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

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
}
