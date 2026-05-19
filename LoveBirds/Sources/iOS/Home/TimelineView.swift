import SwiftUI
import LoveBirdsKit

struct TimelineView: View {
    @Environment(HeartStore.self) private var store

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundGradient()
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(memories) { day in
                            DayCard(day: day, partners: store.partners)
                        }
                        if memories.isEmpty {
                            EmptyState()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Timeline")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var memories: [DayMemory] {
        MemoryEngine.groupByDay(store.hearts)
    }
}

struct DayCard: View {
    let day: DayMemory
    let partners: [Partner]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(day.date, style: .date)
                    .font(.headline)
                Spacer()
                Text("\(day.hearts.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.lbCoral)
            }
            FlowLayout(spacing: 6) {
                ForEach(day.hearts) { heart in
                    Text(heart.vibe.emoji).font(.title3)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.04), in: Capsule())
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.03), in: RoundedRectangle(cornerRadius: 16))
    }
}

struct EmptyState: View {
    var body: some View {
        VStack(spacing: 12) {
            HeartIcon(size: 64)
            Text("No hearts yet").font(.headline)
            Text("Tap the complication on your watch face to send your first one.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding(.top, 60)
        .frame(maxWidth: .infinity)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        return arrange(subviews: subviews, in: width).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let positions = arrange(subviews: subviews, in: bounds.width).positions
        for (subview, point) in zip(subviews, positions) {
            subview.place(at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y), proposal: .unspecified)
        }
    }

    private func arrange(subviews: Subviews, in width: CGFloat) -> (positions: [CGPoint], size: CGSize) {
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            totalHeight = max(totalHeight, y + rowHeight)
        }
        return (positions, CGSize(width: width, height: totalHeight))
    }
}
