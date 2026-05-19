import SwiftUI
import LoveBirdsKit

@main
struct LoveBirdsApp: App {
    @State private var store = HeartStore.shared
    @State private var tipJar = TipJar()
    @State private var pulse = PulseShare()
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .environment(tipJar)
                .environment(pulse)
                .task {
                    await tipJar.load()
                    await SyncEngine.shared.bootstrap()
                    HeartNotifications.shared.registerCategories()
                    _ = await HeartNotifications.shared.requestAuthorization()
                }
                .onOpenURL { url in
                    PairingCoordinator.shared.handle(url: url, into: store)
                }
        }
    }
}
