import SwiftUI
import LoveBirdsKit

struct PartnerCardView: View {
    let partner: Partner
    @Environment(HeartStore.self) private var store

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.lbCoral, partner.color], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 44, height: 44)
                    Text(partner.initials)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.black)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(partner.displayName).font(.headline)
                    if let last = store.lastHeart(for: partner.id) {
                        Text("\(last.direction == .sent ? "You sent" : "\(partner.initials) sent") \(last.vibe.emoji) \(last.sentAt.formatted(.relative(presentation: .numeric)))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Tap to send your first heart")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.tertiary)
            }

            HStack(spacing: 10) {
                StatPill(title: "Streak", value: "\(store.streak(for: partner.id))d")
                StatPill(title: "This week", value: "\(weeklyCount)")
                StatPill(title: "Vibe", value: partner.preferredVibe.emoji)
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private var weeklyCount: Int {
        let weekStart = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
        return store.hearts(for: partner.id).filter { $0.sentAt >= weekStart }.count
    }
}

struct StatPill: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .kerning(1.4)
                .foregroundStyle(.secondary)
            Text(value).font(.subheadline.weight(.semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 10))
    }
}
