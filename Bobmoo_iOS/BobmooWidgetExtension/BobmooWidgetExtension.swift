import SwiftUI
import WidgetKit

struct DietWidget: Widget {
    let kind: String = "DietWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DietProvider()) { entry in
            DietWidgetView(entry: entry)
                .preferredColorScheme(.light)
                .widgetURL({
                    let scheme = Bundle.main.object(forInfoDictionaryKey: "APP_URL_SCHEME") as? String ?? "bobmoo"
                    return URL(string: "\(scheme)://home")
                }())
        }
        .contentMarginsDisabled()
        .configurationDisplayName("Bobmoo Widget")
        .description("학식 정보를 보여주는 위젯입니다.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
