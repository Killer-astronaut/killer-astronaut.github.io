import WidgetKit
import SwiftUI
import LoveBirdsKit

struct StreakWidget: Widget {
    let kind = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HeartComplicationProvider()) { entry in
            StreakWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Streak")
        .description("Days in a row exchanging hearts.")
        .supportedFamilies([.accessoryRectangular, .systemSmall])
    }
}

struct StreakWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: HeartComplicationEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.tint)
                Text("\(entry.streak)")
                    .font(family == .systemSmall ? .system(size: 44, weight: .light) : .title2.weight(.semibold))
            }
            Text("day streak").font(.caption).foregroundStyle(.secondary)
            if let name = entry.partner?.name {
                Text("with \(name)").font(.caption2).foregroundStyle(.secondary)
            }
        }
        .widgetAccentable()
    }
}
