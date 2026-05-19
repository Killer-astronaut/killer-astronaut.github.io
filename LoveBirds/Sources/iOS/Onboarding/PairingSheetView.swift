import SwiftUI
import LoveBirdsKit

struct PairingSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HeartStore.self) private var store
    @State private var inviteName: String = ""
    @State private var invite: PairingInvite?

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundGradient()
                ScrollView {
                    VStack(spacing: 24) {
                        HeartIcon(size: 84)
                            .padding(.top, 24)
                        Text("Pair with someone")
                            .font(.title2.weight(.medium))
                        Text("Generate an invite link they can open on their iPhone. Backed by iCloud Sharing — no account required.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Their name")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            TextField("Name", text: $inviteName)
                                .textFieldStyle(.roundedBorder)
                                .textInputAutocapitalization(.words)
                        }
                        .padding(.horizontal)

                        if let invite {
                            ShareLink(item: invite.universalURL) {
                                Label("Share invite link", systemImage: "square.and.arrow.up.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(LinearGradient(colors: [.lbCoral, .lbRose], startPoint: .leading, endPoint: .trailing))
                                    .foregroundStyle(.black)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .padding(.horizontal)
                        } else {
                            Button {
                                generateInvite()
                            } label: {
                                Text("Create invite")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(LinearGradient(colors: [.lbCoral, .lbRose], startPoint: .leading, endPoint: .trailing))
                                    .foregroundStyle(.black)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .disabled(inviteName.trimmingCharacters(in: .whitespaces).isEmpty)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func generateInvite() {
        let name = inviteName.trimmingCharacters(in: .whitespaces)
        let initials = String(name.prefix(1).uppercased())
        let url = URL(string: "https://getlokei.com/lovebirds/pair?stub=true") ?? URL(string: "https://getlokei.com")!
        invite = PairingInvite(
            inviterName: name,
            inviterInitials: initials,
            colorHex: "#FF6B9D",
            shareURL: url
        )
    }
}
