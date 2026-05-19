import SwiftUI
import LoveBirdsKit

struct OnboardingView: View {
    @Environment(HeartStore.self) private var store
    @State private var name: String = ""
    @State private var partnerName: String = ""
    @State private var step: Step = .welcome

    enum Step { case welcome, you, partner, ready }

    var body: some View {
        ZStack {
            BackgroundGradient()
            VStack(spacing: 28) {
                Spacer()
                stepView
                Spacer()
                primaryButton
            }
            .padding(28)
        }
    }

    @ViewBuilder
    private var stepView: some View {
        switch step {
        case .welcome:
            VStack(spacing: 16) {
                HeartIcon(size: 92)
                Text("Love Birds")
                    .font(.system(size: 36, weight: .light))
                    .kerning(6)
                Text("Two birds. One tap.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Text("Tap your watch. Someone you love feels it.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)
            }

        case .you:
            VStack(spacing: 18) {
                Text("What should they call you?")
                    .font(.title3.weight(.medium))
                TextField("Your name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.words)
                Text("Your name lives on your devices. Lokei never sees it.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

        case .partner:
            VStack(spacing: 18) {
                Text("Who are you pairing with?")
                    .font(.title3.weight(.medium))
                TextField("Their name (or 'Sam')", text: $partnerName)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.words)
                Text("You'll get an invite link to share. It uses iCloud — no account from Love Birds.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

        case .ready:
            VStack(spacing: 16) {
                HeartIcon(size: 80)
                Text("You're set.")
                    .font(.title2.weight(.medium))
                Text("Add the Love Birds complication to your watch face. One tap sends a heart.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var primaryButton: some View {
        Button(action: advance) {
            Text(buttonTitle)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient(colors: [.lbCoral, .lbRose], startPoint: .leading, endPoint: .trailing))
                .foregroundStyle(.black)
                .cornerRadius(30)
        }
        .disabled(!canAdvance)
    }

    private var buttonTitle: String {
        switch step {
        case .welcome: return "Get started"
        case .you: return "Next"
        case .partner: return "Create your pair"
        case .ready: return "Open Love Birds"
        }
    }

    private var canAdvance: Bool {
        switch step {
        case .welcome: return true
        case .you: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case .partner: return !partnerName.trimmingCharacters(in: .whitespaces).isEmpty
        case .ready: return true
        }
    }

    private func advance() {
        switch step {
        case .welcome: step = .you
        case .you: step = .partner
        case .partner:
            let initials = String(partnerName.trimmingCharacters(in: .whitespaces).prefix(1).uppercased())
            let partner = Partner(
                displayName: partnerName.trimmingCharacters(in: .whitespaces),
                initials: initials.isEmpty ? "?" : initials,
                preferredVibe: .heart
            )
            store.addPartner(partner)
            step = .ready
        case .ready:
            break
        }
    }
}

#Preview {
    OnboardingView().environment(HeartStore.shared)
}
