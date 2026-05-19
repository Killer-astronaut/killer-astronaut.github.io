import SwiftUI
import LoveBirdsKit

struct RootView: View {
    @Environment(HeartStore.self) private var store

    var body: some View {
        if store.isOnboarded {
            HomeView()
        } else {
            OnboardingView()
        }
    }
}
