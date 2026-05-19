import SwiftUI
import LoveBirdsKit

struct WatchRootView: View {
    @Environment(HeartStore.self) private var store

    var body: some View {
        if let primary = store.partners.first {
            TabView {
                QuickSendView(partner: primary)
                    .tag(0)
                VibePickerView(partner: primary)
                    .tag(1)
                if store.partners.count > 1 {
                    PartnersWatchListView()
                        .tag(2)
                }
                TimelineWatchView(partner: primary)
                    .tag(3)
            }
            .tabViewStyle(.verticalPage)
        } else {
            UnpairedView()
        }
    }
}

struct UnpairedView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "iphone.gen3")
                .font(.largeTitle)
                .foregroundStyle(.lbCoral)
            Text("Pair on iPhone")
                .font(.headline)
            Text("Open Love Birds on your phone and invite someone first.")
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

extension Color {
    static let lbRose = Color(red: 1.0, green: 0.42, blue: 0.62)
    static let lbCoral = Color(red: 1.0, green: 0.56, blue: 0.64)
}
