import Foundation

extension UserDefaults {
    private static let bobmooAppGroupID = "group.soseoyo.BabmooiOS"

    static var bobmooShared: UserDefaults {
        UserDefaults(suiteName: bobmooAppGroupID) ?? .standard
    }
}
