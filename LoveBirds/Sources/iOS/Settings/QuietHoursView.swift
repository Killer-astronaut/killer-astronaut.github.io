import SwiftUI
import LoveBirdsKit

struct QuietHoursView: View {
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var respectFocus = true

    var body: some View {
        Form {
            Section("Mute haptics between") {
                DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                DatePicker("End", selection: $endTime, displayedComponents: .hourAndMinute)
            }
            Section {
                Toggle("Also respect Focus modes", isOn: $respectFocus)
            } footer: {
                Text("Honors Sleep, Work, Do Not Disturb, and any custom Focus filters automatically.")
            }
        }
        .scrollContentBackground(.hidden)
        .background(BackgroundGradient())
        .navigationTitle("Quiet Hours")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ImportantDatesView: View {
    @Environment(HeartStore.self) private var store
    @State private var newDate = Date()
    @State private var newLabel = ""

    var body: some View {
        List {
            ForEach(store.partners) { partner in
                Section(partner.displayName) {
                    ForEach(partner.importantDates) { date in
                        HStack {
                            Text(date.emoji).font(.title3)
                            VStack(alignment: .leading) {
                                Text(date.label)
                                Text(date.date, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(BackgroundGradient())
        .navigationTitle("Important Dates")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy")
                    .font(.title.weight(.medium))
                Group {
                    Text("Love Birds collects no data, contains no analytics SDKs, and contains no advertising. Pairing happens over Apple's iCloud Sharing — there is no Love Birds account.")
                    Text("Heart messages flow through a CloudKit shared zone owned jointly by the two paired Apple Accounts. Apple manages the encryption keys. Lokei has no server in the path.")
                    Text("Heart-rate readings during a Pulse Share are read from HealthKit, played as haptics on the partner's wrist, and forgotten. Nothing is written to HealthKit, nothing is uploaded, nothing is retained.")
                    Text("The optional long-distance map only shares a coarse-rounded \"home zone\" coordinate, never a live location and never a route. You can turn it off at any time.")
                }
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
            }
            .padding()
        }
        .background(BackgroundGradient())
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}
