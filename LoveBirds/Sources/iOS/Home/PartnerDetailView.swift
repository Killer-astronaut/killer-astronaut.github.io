import SwiftUI
import LoveBirdsKit

struct PartnerDetailView: View {
    let partner: Partner
    @Environment(HeartStore.self) private var store
    @State private var showingComposer = false
    @State private var showingPulse = false

    var body: some View {
        ZStack {
            BackgroundGradient()
            ScrollView {
                VStack(spacing: 24) {
                    sendCard
                    quickActions
                    timelinePreview
                }
                .padding()
            }
        }
        .navigationTitle(partner.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Edit", systemImage: "pencil") {}
                    Button("Remove", systemImage: "trash", role: .destructive) {
                        store.removePartner(id: partner.id)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingComposer) {
            HapticComposerView()
        }
        .sheet(isPresented: $showingPulse) {
            PulseShareView(partner: partner)
        }
    }

    private var sendCard: some View {
        VStack(spacing: 16) {
            HeartIcon(size: 96, tint: partner.color)
            Text("Tap below to send")
                .font(.caption)
                .foregroundStyle(.secondary)
            VibeGrid(partner: partner)
        }
        .padding(24)
        .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private var quickActions: some View {
        HStack(spacing: 12) {
            ActionTile(title: "Pulse", icon: "waveform.path.ecg") { showingPulse = true }
            ActionTile(title: "Haptics", icon: "waveform") { showingComposer = true }
            ActionTile(title: "Memories", icon: "photo.on.rectangle.angled") {}
        }
    }

    private var timelinePreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent")
                    .font(.headline)
                Spacer()
                Text("\(store.hearts(for: partner.id).count) total").font(.caption).foregroundStyle(.secondary)
            }
            VStack(spacing: 8) {
                ForEach(store.hearts(for: partner.id).prefix(10)) { heart in
                    HeartRow(heart: heart, partner: partner)
                }
            }
        }
    }
}

struct VibeGrid: View {
    let partner: Partner
    @Environment(HeartStore.self) private var store

    private let columns = [GridItem(.adaptive(minimum: 64), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(HeartVibe.allCases) { vibe in
                VibeButton(vibe: vibe) {
                    send(vibe)
                }
            }
        }
    }

    private func send(_ vibe: HeartVibe) {
        let heart = store.recordSent(partnerID: partner.id, vibe: vibe)
        HapticEngine.shared.play(pattern: store.pattern(id: heart.hapticPatternID))
        LiveActivityCoordinator.shared.start(for: partner, with: heart)
        Task { await SyncEngine.shared.sendHeart(heart, on: partner) }
    }
}

struct VibeButton: View {
    let vibe: HeartVibe
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(vibe.emoji).font(.system(size: 30))
                Text(vibe.label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

struct ActionTile: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon).font(.title2).foregroundStyle(.lbCoral)
                Text(title).font(.caption.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .padding(14)
            .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

struct HeartRow: View {
    let heart: Heart
    let partner: Partner

    var body: some View {
        HStack(spacing: 12) {
            Text(heart.vibe.emoji).font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(heart.direction == .sent ? "You sent" : "\(partner.displayName) sent")
                    .font(.subheadline.weight(.medium))
                Text(heart.sentAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            if heart.direction == .sent {
                Image(systemName: "arrow.up.right").foregroundStyle(.lbCoral)
            } else {
                Image(systemName: "arrow.down.left").foregroundStyle(.lbBlue)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.03), in: RoundedRectangle(cornerRadius: 12))
    }
}
