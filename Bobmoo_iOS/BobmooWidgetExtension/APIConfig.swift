import Foundation

enum APIConfig {
    static var baseURL: URL {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String,
              let url = URL(string: raw) else {
            preconditionFailure("Missing or invalid BASE_URL in Widget Info.plist")
        }
        return url
    }
}
