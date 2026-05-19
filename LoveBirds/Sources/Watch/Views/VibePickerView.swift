import SwiftUI
import LoveBirdsKit

struct VibePickerView: View {
    let partner: Partner
    @Environment(HeartStore.self) private var store

    private let columns = [GridItem(.adaptive(minimum: 50), spacing: 6)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Send \(partner.displayName) a vibe")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(HeartVibe.allCases) { vibe in
                        Button {
                            send(vibe)
                        } label: {
                            VStack(spacing: 2) {
                                Text(vibe.emoji).font(.title2)
                                Text(vibe.label).font(.system(size: 8))
                                    .lineLimit(1)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 52, height: 52)
                            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func send(_ vibe: HeartVibe) {
        let heart = store.recordSent(partnerID: partner.id, vibe: vibe)
        HapticEngine.shared.play(pattern: store.pattern(id: heart.hapticPatternID))
        Task { await SyncEngine.shared.sendHeart(heart, on: partner) }
    }
}
