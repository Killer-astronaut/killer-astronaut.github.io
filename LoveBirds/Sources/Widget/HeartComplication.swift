import WidgetKit
import SwiftUI
import AppIntents
import LoveBirdsKit

struct HeartComplicationEntry: TimelineEntry {
    let date: Date
    let partner: PartnerSnapshot?
    let lastHeartVibe: HeartVibe?
    let streak: Int
}

struct PartnerSnapshot: Hashable {
    let id: UUID
    let name: String
    let initials: String
    let colorHex: String
}

struct HeartComplicationProvider: TimelineProvider {
    func placeholder(in context: Context) -> HeartComplicationEntry {
        HeartComplicationEntry(date: .now, partner: PartnerSnapshot(id: UUID(), name: "Sam", initials: "S", colorHex: "#FF6B9D"), lastHeartVibe: .heart, streak: 12)
    }

    func getSnapshot(in context: Context, completion: @escaping (HeartComplicationEntry) -> Void) {
        Task { @MainActor in
            completion(currentEntry())
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HeartComplicationEntry>) -> Void) {
        Task { @MainActor in
            let entry = currentEntry()
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 15)))
            completion(timeline)
        }
    }

    @MainActor
    private func currentEntry() -> HeartComplicationEntry {
        let store = HeartStore.shared
        if let partner = store.partners.first {
            return HeartComplicationEntry(
                date: .now,
                partner: PartnerSnapshot(id: partner.id, name: partner.displayName, initials: partner.initials, colorHex: partner.colorHex),
                lastHeartVibe: store.lastHeart(for: partner.id)?.vibe,
                streak: store.streak(for: partner.id)
            )
        }
        return HeartComplicationEntry(date: .now, partner: nil, lastHeartVibe: nil, streak: 0)
    }
}

struct HeartComplication: Widget {
    let kind = "HeartComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HeartComplicationProvider()) { entry in
            HeartComplicationView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Love Birds")
        .description("Tap to send an instant heart.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryInline,
            .accessoryRectangular
        ])
    }
}

struct HeartComplicationView: View {
    @Environment(\.widgetFamily) var family
    let entry: HeartComplicationEntry

    var body: some View {
        switch family {
        case .accessoryCircular: circular
        case .accessoryCorner: corner
        case .accessoryInline: inline
        case .accessoryRectangular: rectangular
        default: circular
        }
    }

    private var circular: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 18, weight: .bold))
                if let name = entry.partner?.initials {
                    Text(name).font(.system(size: 9, weight: .bold))
                }
            }
            .foregroundStyle(.tint)
            .widgetAccentable()
        }
        .widgetURL(URL(string: "lovebirds://send"))
    }

    private var corner: some View {
        Image(systemName: "heart.fill")
            .foregroundStyle(.tint)
            .widgetAccentable()
            .widgetLabel {
                Text(entry.partner?.name ?? "Tap")
            }
            .widgetURL(URL(string: "lovebirds://send"))
    }

    private var inline: some View {
        Label("\(entry.partner?.name ?? "Tap a heart")", systemImage: "heart.fill")
            .widgetURL(URL(string: "lovebirds://send"))
    }

    private var rectangular: some View {
        HStack(spacing: 8) {
            Image(systemName: "heart.fill")
                .font(.title2)
                .foregroundStyle(.tint)
            VStack(alignment: .leading) {
                Text(entry.partner?.name ?? "Pair on iPhone").font(.headline)
                if let vibe = entry.lastHeartVibe {
                    Text("Last: \(vibe.label)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(entry.streak) day streak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .widgetAccentable()
        .widgetURL(URL(string: "lovebirds://send"))
    }
}
