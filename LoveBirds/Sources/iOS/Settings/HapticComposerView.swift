import SwiftUI
import LoveBirdsKit

struct HapticComposerView: View {
    @Environment(HeartStore.self) private var store
    @State private var composer = HapticComposer()
    @State private var selectedPatternID: HapticPattern.ID = HapticPattern.builtIn.tap.id

    var body: some View {
        ZStack {
            BackgroundGradient()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Pick a starting pattern, then tap below to add your own beats.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    Picker("Starting pattern", selection: $selectedPatternID) {
                        ForEach(store.patterns()) { pattern in
                            Text(pattern.displayName).tag(pattern.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedPatternID) { _, new in
                        composer.loadFrom(store.pattern(id: new))
                    }
                    .padding(.horizontal)

                    TimelineCanvas(events: composer.events) { time in
                        composer.addTap(at: time, intensity: 0.85, sharpness: 0.6)
                    }
                    .frame(height: 120)
                    .padding(.horizontal)

                    HStack {
                        Button("Play") {
                            HapticEngine.shared.play(pattern: composer.build())
                        }
                        Spacer()
                        Button("Clear", role: .destructive) {
                            composer.clear()
                        }
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pattern name").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                        TextField("My pattern", text: Binding(get: { composer.name }, set: { composer.name = $0 }))
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)

                    Button {
                        store.saveCustomPattern(composer.build())
                    } label: {
                        Text("Save pattern")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(colors: [.lbCoral, .lbRose], startPoint: .leading, endPoint: .trailing))
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("Haptic Composer")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            composer.loadFrom(store.pattern(id: selectedPatternID))
        }
    }
}

struct TimelineCanvas: View {
    let events: [HapticPattern.Event]
    let onTap: (Double) -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.lbRose.opacity(0.25), lineWidth: 1)
                    )

                let maxTime = max(events.map(\.time).max() ?? 0, 1.5) + 0.2

                ForEach(Array(events.enumerated()), id: \.offset) { _, event in
                    Circle()
                        .fill(Color.lbCoral.opacity(0.6 + event.intensity * 0.4))
                        .frame(width: 12 + event.intensity * 14, height: 12 + event.intensity * 14)
                        .position(x: (event.time / maxTime) * geo.size.width, y: geo.size.height / 2)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { location in
                let maxTime = max(events.map(\.time).max() ?? 0, 1.5) + 0.2
                let time = (location.x / geo.size.width) * maxTime
                onTap(max(0, time))
            }
        }
    }
}
