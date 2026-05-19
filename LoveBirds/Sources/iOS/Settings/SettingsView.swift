import SwiftUI
import LoveBirdsKit

struct SettingsView: View {
    @Environment(HeartStore.self) private var store
    @Environment(TipJar.self) private var tipJar
    @AppStorage("reduceMotion") private var reduceMotion = false
    @AppStorage("respectFocus") private var respectFocus = true
    @AppStorage("smartNudges") private var smartNudges = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Privacy") {
                    Label("No account required", systemImage: "person.crop.circle.badge.checkmark")
                    Label("End-to-end via iCloud", systemImage: "lock.icloud.fill")
                    Label("No analytics", systemImage: "eye.slash.fill")
                    NavigationLink("Privacy Policy") { PrivacyView() }
                }

                Section("Delivery") {
                    Toggle("Respect Focus modes", isOn: $respectFocus)
                    Toggle("Smart nudges (on-device)", isOn: $smartNudges)
                    Toggle("Reduce motion", isOn: $reduceMotion)
                    NavigationLink("Quiet hours") { QuietHoursView() }
                }

                Section("Customize") {
                    NavigationLink("Haptic patterns") { HapticComposerView() }
                    NavigationLink("Important dates") { ImportantDatesView() }
                }

                Section("Love Birds") {
                    NavigationLink("Tip jar") { TipJarView() }
                    LabeledContent("Version", value: appVersion)
                }

                Section {
                    Link("From the makers of Lokei", destination: URL(string: "https://getlokei.com")!)
                        .foregroundStyle(.lbCoral)
                }
            }
            .scrollContentBackground(.hidden)
            .background(BackgroundGradient())
            .navigationTitle("Settings")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }
}
