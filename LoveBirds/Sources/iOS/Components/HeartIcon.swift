import SwiftUI
import LoveBirdsKit

struct HeartIcon: View {
    let size: CGFloat
    var tint: Color = .lbRose
    var animate: Bool = true

    @State private var beat = false

    var body: some View {
        ZStack {
            Circle()
                .fill(tint.opacity(0.15))
                .blur(radius: size * 0.15)
            Image(systemName: "heart.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(
                    LinearGradient(
                        colors: [.lbCoral, tint],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(beat ? 1.08 : 1.0)
                .shadow(color: tint.opacity(0.5), radius: 16, y: 4)
        }
        .frame(width: size, height: size)
        .onAppear {
            guard animate else { return }
            withAnimation(.easeInOut(duration: 0.85).repeatForever(autoreverses: true)) {
                beat = true
            }
        }
    }
}

struct BackgroundGradient: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            RadialGradient(
                colors: [.lbRose.opacity(0.18), .clear],
                center: .topLeading,
                startRadius: 50,
                endRadius: 420
            )
            .ignoresSafeArea()
            RadialGradient(
                colors: [.lbBlue.opacity(0.10), .clear],
                center: .bottomTrailing,
                startRadius: 50,
                endRadius: 380
            )
            .ignoresSafeArea()
        }
    }
}

extension Color {
    static let lbRose = Color(red: 1.0, green: 0.42, blue: 0.62)
    static let lbCoral = Color(red: 1.0, green: 0.56, blue: 0.64)
    static let lbTeal = Color(red: 0.0, green: 1.0, blue: 0.80)
    static let lbBlue = Color(red: 0.0, green: 0.80, blue: 1.0)
}
