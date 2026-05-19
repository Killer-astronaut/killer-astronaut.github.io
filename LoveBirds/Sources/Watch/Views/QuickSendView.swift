import SwiftUI
import LoveBirdsKit

struct QuickSendView: View {
    let partner: Partner
    @Environment(HeartStore.self) private var store
    @State private var sentPulse = false
    @State private var ringScale: CGFloat = 0.8
    @State private var lastSent: Date?

    var body: some View {
        ZStack {
            background

            VStack(spacing: 6) {
                Spacer()
                Text(partner.displayName)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .kerning(1.5)
                ZStack {
                    Circle()
                        .stroke(partner.color.opacity(0.4), lineWidth: 2)
                        .scaleEffect(ringScale)
                        .opacity(sentPulse ? 0 : 0.6)
                    bigHeart
                        .scaleEffect(sentPulse ? 1.18 : 1.0)
                }
                .frame(maxHeight: .infinity)
                .contentShape(Circle())
                .onTapGesture {
                    send()
                }
                Text(lastSent == nil ? "Tap to send" : "Sent \(timeAgo) ago")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }

    private var background: some View {
        RadialGradient(colors: [partner.color.opacity(0.20), .clear], center: .center, startRadius: 5, endRadius: 130)
            .ignoresSafeArea()
    }

    private var bigHeart: some View {
        Image(systemName: "heart.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 84, height: 84)
            .foregroundStyle(LinearGradient(colors: [.lbCoral, partner.color], startPoint: .topLeading, endPoint: .bottomTrailing))
            .shadow(color: partner.color.opacity(0.7), radius: 10, y: 2)
    }

    private var timeAgo: String {
        guard let lastSent else { return "" }
        let interval = Date().timeIntervalSince(lastSent)
        if interval < 60 { return "now" }
        if interval < 3600 { return "\(Int(interval/60))m" }
        return "\(Int(interval/3600))h"
    }

    private func send() {
        let heart = store.recordSent(partnerID: partner.id, vibe: partner.preferredVibe)
        HapticEngine.shared.play(pattern: store.pattern(id: heart.hapticPatternID))
        Task { await SyncEngine.shared.sendHeart(heart, on: partner) }
        lastSent = .now

        withAnimation(.easeOut(duration: 0.7)) {
            ringScale = 1.6
            sentPulse = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeIn(duration: 0.2)) {
                ringScale = 0.8
                sentPulse = false
            }
        }
    }
}
