import SwiftUI
import LoveBirdsKit

struct MessagesRootView: View {
    let onSelectVibe: (HeartVibe) -> Void

    private let columns = [GridItem(.adaptive(minimum: 80), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Send a Love Birds vibe")
                    .font(.headline)
                    .padding(.horizontal)
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(HeartVibe.allCases) { vibe in
                        Button { onSelectVibe(vibe) } label: {
                            VStack(spacing: 6) {
                                Text(vibe.emoji).font(.system(size: 40))
                                Text(vibe.label).font(.caption).foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}
