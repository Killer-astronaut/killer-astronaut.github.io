import SwiftUI
import LoveBirdsKit

struct TimelineWatchView: View {
    let partner: Partner
    @Environment(HeartStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                Text("Recent").font(.caption2.weight(.semibold)).foregroundStyle(.secondary)
                ForEach(store.hearts(for: partner.id).prefix(20)) { heart in
                    HStack(spacing: 8) {
                        Text(heart.vibe.emoji).font(.title3)
                        VStack(alignment: .leading) {
                            Text(heart.direction == .sent ? "Sent" : "Received")
                                .font(.system(size: 11, weight: .semibold))
                            Text(heart.sentAt, style: .relative)
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(8)
                    .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}
