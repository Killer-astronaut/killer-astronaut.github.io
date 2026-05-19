import SwiftUI
import LoveBirdsKit

struct PartnersWatchListView: View {
    @Environment(HeartStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                ForEach(store.partners) { partner in
                    NavigationLink {
                        QuickSendView(partner: partner)
                    } label: {
                        HStack {
                            Circle()
                                .fill(partner.color)
                                .frame(width: 22, height: 22)
                                .overlay(Text(partner.initials).font(.caption2.weight(.bold)).foregroundStyle(.black))
                            Text(partner.displayName)
                                .font(.subheadline.weight(.medium))
                            Spacer()
                            Text("\(store.streak(for: partner.id))d")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
}
