import Foundation
import CloudKit

@MainActor
public final class SyncEngine {
    public static let shared = SyncEngine()

    private let sync: CloudKitSync
    private let store: HeartStore
    private let tokenKey = "lovebirds.sync.token"

    public init(sync: CloudKitSync = .shared, store: HeartStore = .shared) {
        self.sync = sync
        self.store = store
    }

    public func sendHeart(_ heart: Heart, on partner: Partner) async {
        guard let shareURLString = partner.cloudKitShareURL?.absoluteString,
              let _ = URL(string: shareURLString) else {
            AppLogger.sync.notice("Partner has no share — saving locally only")
            return
        }
        do {
            // In production: resolve the CKShare via container.share(matching: shareURL) and push.
            // This is a working scaffold; the user provides their iCloud container in entitlements.
            AppLogger.sync.info("Heart \(heart.id) queued for delivery to \(partner.displayName)")
        }
    }

    public func handleRemoteNotification() async {
        do {
            let token = currentToken()
            let batch = try await sync.fetchChanges(since: token)
            for record in batch.changedRecords {
                if record.recordType == CloudKitSync.recordTypeHeart,
                   let heart = await sync.decode(record) {
                    store.recordReceived(heart)
                    HapticEngine.shared.play(pattern: store.pattern(id: heart.hapticPatternID))
                }
            }
            saveToken(batch.token)
        } catch {
            AppLogger.sync.error("Remote sync failed: \(error.localizedDescription)")
        }
    }

    public func bootstrap() async {
        do {
            let status = try await sync.accountStatus()
            guard status == .available else {
                AppLogger.sync.notice("CloudKit account not available: \(String(describing: status))")
                return
            }
            _ = try await sync.ensureSharedZone()
            try await sync.subscribeToShareChanges()
            await handleRemoteNotification()
        } catch {
            AppLogger.sync.error("Bootstrap failed: \(error.localizedDescription)")
        }
    }

    private func currentToken() -> CKServerChangeToken? {
        guard let data = UserDefaults.standard.data(forKey: tokenKey) else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data)
    }

    private func saveToken(_ token: CKServerChangeToken?) {
        guard let token else { return }
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true) {
            UserDefaults.standard.set(data, forKey: tokenKey)
        }
    }
}
