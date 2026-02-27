import SwiftUI
import WidgetKit

struct DietWidget: Widget {
    let kind: String = "DietWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DietProvider()) { entry in
            DietWidgetView(entry: entry)
                .widgetURL(URL(string: "bobmoo://home"))
        }
        .configurationDisplayName("Bobmoo Widget")
        .description("학식 정보를 보여주는 위젯입니다.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
