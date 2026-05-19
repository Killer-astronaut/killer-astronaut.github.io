import SwiftUI
import StoreKit
import LoveBirdsKit

struct TipJarView: View {
    @Environment(TipJar.self) private var tipJar
    @Environment(HeartStore.self) private var store
    @State private var thankYouVisible = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HeartIcon(size: 84)
                    .padding(.top, 24)
                Text("Tip jar")
                    .font(.title2.weight(.medium))
                Text("Everything is unlocked. If you want to throw something extra in, here's the jar.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                ForEach(TipProduct.allCases, id: \.self) { tip in
                    TipRow(tip: tip)
                }

                if store.tipsGiven > 0 {
                    Label("You've supported Love Birds \(store.tipsGiven) \(store.tipsGiven == 1 ? "time" : "times"). Thank you!", systemImage: "sparkles")
                        .font(.footnote)
                        .padding()
                        .background(Color.lbRose.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(BackgroundGradient())
        .navigationTitle("Tip Jar")
        .navigationBarTitleDisplayMode(.inline)
        .task { await tipJar.load() }
    }
}

struct TipRow: View {
    let tip: TipProduct
    @Environment(TipJar.self) private var tipJar
    @State private var purchasing = false

    var body: some View {
        Button {
            purchasing = true
            Task {
                _ = await tipJar.purchase(tip)
                purchasing = false
            }
        } label: {
            HStack(spacing: 16) {
                Text(tip.emoji).font(.title)
                VStack(alignment: .leading) {
                    Text(tip.label).font(.headline)
                    Text(displayPrice).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if purchasing {
                    ProgressView()
                } else {
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.lbCoral)
                }
            }
            .padding()
            .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }

    private var displayPrice: String {
        tipJar.products.first(where: { $0.id == tip.rawValue })?.displayPrice ?? tip.displayPriceHint
    }
}
