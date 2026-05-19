import SwiftUI
import LoveBirdsKit

struct HomeView: View {
    @Environment(HeartStore.self) private var store

    var body: some View {
        TabView {
            partnersTab
                .tabItem { Label("Hearts", systemImage: "heart.fill") }

            TimelineView()
                .tabItem { Label("Timeline", systemImage: "clock.fill") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(.lbRose)
    }

    private var partnersTab: some View {
        NavigationStack {
            ZStack {
                BackgroundGradient()
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if let firstPartner = store.partners.first {
                            ForEach(store.nudges(for: firstPartner)) { nudge in
                                NudgeCard(nudge: nudge)
                            }
                        }
                        ForEach(store.partners) { partner in
                            NavigationLink(value: partner) {
                                PartnerCardView(partner: partner)
                            }
                            .buttonStyle(.plain)
                        }
                        AddPartnerButton()
                    }
                    .padding()
                }
            }
            .navigationTitle("Love Birds")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(for: Partner.self) { partner in
                PartnerDetailView(partner: partner)
            }
        }
    }
}

struct NudgeCard: View {
    let nudge: SmartNudge

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: nudge.suggestedVibe.symbol)
                .font(.title2)
                .foregroundStyle(.lbRose)
                .frame(width: 36, height: 36)
                .background(Color.lbRose.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(nudge.title).font(.headline)
                Text(nudge.body).font(.footnote).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.lbRose.opacity(0.2), lineWidth: 1)
        )
    }
}

struct AddPartnerButton: View {
    @State private var presentingPair = false
    @Environment(HeartStore.self) private var store

    var body: some View {
        Button {
            presentingPair = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("Pair with someone new")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.lbRose.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(.lbCoral)
        }
        .sheet(isPresented: $presentingPair) {
            PairingSheetView()
        }
    }
}

#Preview {
    HomeView().environment(HeartStore.shared)
}
