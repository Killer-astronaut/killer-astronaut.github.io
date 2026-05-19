import WidgetKit
import SwiftUI
import LoveBirdsKit

struct HeartLockScreenWidget: Widget {
    let kind = "HeartLockScreen"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HeartComplicationProvider()) { entry in
            LockScreenView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Send a Heart")
        .description("One-tap from your Lock Screen or StandBy.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct LockScreenView: View {
    @Environment(\.widgetFamily) var family
    let entry: HeartComplicationEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.42, blue: 0.62).opacity(0.30), Color(red: 0.0, green: 0.80, blue: 1.0).opacity(0.10)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: 6) {
                Image(systemName: "heart.fill")
                    .font(.system(size: family == .systemSmall ? 36 : 44, weight: .bold))
                    .foregroundStyle(LinearGradient(colors: [Color(red: 1.0, green: 0.56, blue: 0.64), Color(red: 1.0, green: 0.42, blue: 0.62)], startPoint: .top, endPoint: .bottom))
                if let partner = entry.partner {
                    Text("Tap \(partner.name)").font(.caption.weight(.semibold))
                    if entry.streak > 0 {
                        Text("\(entry.streak)-day streak")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("Open to pair").font(.caption)
                }
            }
        }
        .widgetURL(URL(string: "lovebirds://send"))
    }
}
