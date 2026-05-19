import SwiftUI
import LoveBirdsKit

struct PulseShareView: View {
    let partner: Partner
    @Environment(\.dismiss) private var dismiss
    @Environment(PulseShare.self) private var pulse
    @Environment(HeartStore.self) private var store
    @State private var holding = false
    @State private var authorized = false

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundGradient()
                VStack(spacing: 32) {
                    Spacer()
                    HeartIcon(size: 140, tint: partner.color)
                        .scaleEffect(holding ? 1.08 : 1.0)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: holding)
                    if let bpm = pulse.currentBPM {
                        Text("\(bpm) BPM")
                            .font(.system(size: 56, weight: .light, design: .rounded))
                    } else if holding {
                        Text("Reading...").foregroundStyle(.secondary)
                    } else {
                        Text("Press and hold")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    Text("Your partner will feel your heart rate on their wrist as a haptic rhythm. Nothing is stored.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal)
                    Spacer()
                    holdButton
                        .padding(.bottom, 28)
                }
                .padding()
            }
            .navigationTitle("Pulse Share")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                authorized = await pulse.requestAuthorization()
            }
        }
    }

    private var holdButton: some View {
        Circle()
            .fill(LinearGradient(colors: [.lbCoral, .lbRose], startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: 96, height: 96)
            .overlay(
                Image(systemName: "waveform.path.ecg")
                    .font(.title)
                    .foregroundStyle(.black)
            )
            .scaleEffect(holding ? 1.1 : 1.0)
            .shadow(color: .lbRose.opacity(0.6), radius: holding ? 28 : 16)
            .gesture(
                LongPressGesture(minimumDuration: 0.1)
                    .onChanged { _ in startHolding() }
                    .onEnded { _ in stopHolding() }
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !holding { startHolding() }
                    }
                    .onEnded { _ in stopHolding() }
            )
            .opacity(authorized ? 1 : 0.5)
            .disabled(!authorized)
    }

    private func startHolding() {
        guard !holding else { return }
        holding = true
        pulse.start()
        if let bpm = pulse.currentBPM {
            HapticEngine.shared.play(pattern: PulseShare.pattern(forBPM: bpm))
        }
    }

    private func stopHolding() {
        holding = false
        if let bpm = pulse.currentBPM {
            let heart = store.recordSent(partnerID: partner.id, vibe: .heartbeat, hapticPatternID: PulseShare.pattern(forBPM: bpm).id, pulseBPM: bpm)
            Task { await SyncEngine.shared.sendHeart(heart, on: partner) }
        }
        pulse.stop()
    }
}
