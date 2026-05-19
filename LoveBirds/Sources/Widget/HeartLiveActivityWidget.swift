import WidgetKit
import SwiftUI
import ActivityKit
import LoveBirdsKit

struct HeartLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HeartActivityAttributes.self) { context in
            LockScreenLiveActivity(context: context)
                .activityBackgroundTint(Color.black.opacity(0.6))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    initialsView(context: context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.vibe.emoji)
                        .font(.title)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.attributes.partnerName).font(.headline)
                        Spacer()
                        if let bpm = context.state.bpm {
                            Label("\(bpm) BPM", systemImage: "waveform.path.ecg")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text(context.state.sentAt, style: .relative)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } compactLeading: {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.lbCoral)
            } compactTrailing: {
                Text(context.state.vibe.emoji)
            } minimal: {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.lbCoral)
            }
            .keylineTint(.lbCoral)
        }
    }

    private func initialsView(context: ActivityViewContext<HeartActivityAttributes>) -> some View {
        Circle()
            .fill(LinearGradient(colors: [.lbCoral, Color(hex: context.attributes.colorHex) ?? .lbCoral], startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: 32, height: 32)
            .overlay(Text(context.attributes.initials).font(.caption.weight(.bold)).foregroundStyle(.black))
    }
}

struct LockScreenLiveActivity: View {
    let context: ActivityViewContext<HeartActivityAttributes>

    var body: some View {
        HStack {
            Circle()
                .fill(LinearGradient(colors: [.lbCoral, Color(hex: context.attributes.colorHex) ?? .lbCoral], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(context.attributes.initials)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.black)
                )
            VStack(alignment: .leading) {
                Text(context.attributes.partnerName).font(.headline)
                Text("Sent \(context.state.vibe.emoji) \(context.state.vibe.label)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(context.state.vibe.emoji).font(.system(size: 32))
        }
        .padding()
    }
}

extension Color {
    static let lbCoral = Color(red: 1.0, green: 0.56, blue: 0.64)
}

extension Color {
    init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        guard s.count == 6, let rgb = UInt64(s, radix: 16) else { return nil }
        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
