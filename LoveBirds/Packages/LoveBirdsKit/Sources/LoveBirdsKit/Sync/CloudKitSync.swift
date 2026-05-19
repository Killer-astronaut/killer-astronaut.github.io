import Foundation
import CloudKit

public actor CloudKitSync {
    public static let shared = CloudKitSync()

    public static let containerIdentifier = "iCloud.com.lokei.lovebirds"
    public static let sharedZoneName = "LoveBirdsShared"
    public static let recordTypeHeart = "Heart"
    public static let recordTypePartner = "Partner"

    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let sharedDatabase: CKDatabase

    public init(container: CKContainer = CKContainer(identifier: CloudKitSync.containerIdentifier)) {
        self.container = container
        self.privateDatabase = container.privateCloudDatabase
        self.sharedDatabase = container.sharedCloudDatabase
    }

    public func accountStatus() async throws -> CKAccountStatus {
        try await container.accountStatus()
    }

    public func ensureSharedZone() async throws -> CKRecordZone {
        let zoneID = CKRecordZone.ID(zoneName: Self.sharedZoneName, ownerName: CKCurrentUserDefaultName)
        do {
            return try await privateDatabase.recordZone(for: zoneID)
        } catch {
            let zone = CKRecordZone(zoneID: zoneID)
            try await privateDatabase.save(zone)
            return zone
        }
    }

    public func createShareForPairing(rootRecord: CKRecord) async throws -> CKShare {
        let share = CKShare(rootRecord: rootRecord)
        share[CKShare.SystemFieldKey.title] = "Love Birds" as CKRecordValue
        share.publicPermission = .none
        try await privateDatabase.modifyRecords(saving: [rootRecord, share], deleting: [])
        return share
    }

    public func push(heart: Heart, to share: CKShare) async throws {
        let zoneID = share.recordID.zoneID
        let recordID = CKRecord.ID(recordName: heart.id.uuidString, zoneID: zoneID)
        let record = CKRecord(recordType: Self.recordTypeHeart, recordID: recordID)
        record["partnerID"] = heart.partnerID.uuidString as CKRecordValue
        record["vibe"] = heart.vibe.rawValue as CKRecordValue
        record["sentAt"] = heart.sentAt as CKRecordValue
        record["direction"] = heart.direction.rawValue as CKRecordValue
        record["hapticPatternID"] = heart.hapticPatternID as CKRecordValue
        if let bpm = heart.pulseBPM {
            record["pulseBPM"] = bpm as CKRecordValue
        }
        let database = share.owner.userIdentity.userRecordID == nil ? sharedDatabase : privateDatabase
        try await database.save(record)
    }

    public func fetchChanges(since token: CKServerChangeToken?) async throws -> ChangeBatch {
        let zoneID = CKRecordZone.ID(zoneName: Self.sharedZoneName, ownerName: CKCurrentUserDefaultName)
        let config = CKFetchRecordZoneChangesOperation.ZoneConfiguration(
            previousServerChangeToken: token,
            resultsLimit: nil,
            desiredKeys: nil
        )
        let op = CKFetchRecordZoneChangesOperation(
            recordZoneIDs: [zoneID],
            configurationsByRecordZoneID: [zoneID: config]
        )

        var changed: [CKRecord] = []
        var deleted: [CKRecord.ID] = []
        var newToken: CKServerChangeToken? = token

        op.recordWasChangedBlock = { _, result in
            if case .success(let record) = result { changed.append(record) }
        }
        op.recordWithIDWasDeletedBlock = { id, _ in
            deleted.append(id)
        }
        op.recordZoneChangeTokensUpdatedBlock = { _, token, _ in
            newToken = token
        }
        op.recordZoneFetchResultBlock = { _, result in
            if case .success(let (token, _, _)) = result {
                newToken = token
            }
        }

        return try await withCheckedThrowingContinuation { continuation in
            op.fetchRecordZoneChangesResultBlock = { result in
                switch result {
                case .success:
                    continuation.resume(returning: ChangeBatch(changedRecords: changed, deletedRecordIDs: deleted, token: newToken))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            self.privateDatabase.add(op)
        }
    }

    public struct ChangeBatch: Sendable {
        public let changedRecords: [CKRecord]
        public let deletedRecordIDs: [CKRecord.ID]
        public let token: CKServerChangeToken?
    }

    public func subscribeToShareChanges() async throws {
        let zoneID = CKRecordZone.ID(zoneName: Self.sharedZoneName, ownerName: CKCurrentUserDefaultName)
        let subscription = CKRecordZoneSubscription(zoneID: zoneID, subscriptionID: "love-birds-share")
        subscription.notificationInfo = {
            let info = CKSubscription.NotificationInfo()
            info.shouldSendContentAvailable = true
            info.alertBody = "" // silent — we draw our own UI
            return info
        }()
        do {
            _ = try await privateDatabase.save(subscription)
        } catch let error as CKError where error.code == .serverRejectedRequest {
            // Already exists — ignore
        }
    }
}

public extension CloudKitSync {
    func decode(_ record: CKRecord) -> Heart? {
        guard
            let partnerString = record["partnerID"] as? String,
            let partnerUUID = UUID(uuidString: partnerString),
            let vibeRaw = record["vibe"] as? String,
            let vibe = HeartVibe(rawValue: vibeRaw),
            let sentAt = record["sentAt"] as? Date,
            let directionRaw = record["direction"] as? String,
            let direction = Heart.Direction(rawValue: directionRaw),
            let patternID = record["hapticPatternID"] as? String,
            let heartID = UUID(uuidString: record.recordID.recordName)
        else { return nil }
        return Heart(
            id: heartID,
            partnerID: partnerUUID,
            vibe: vibe,
            sentAt: sentAt,
            direction: direction == .sent ? .received : .sent,
            hapticPatternID: patternID,
            deliveredAt: Date(),
            pulseBPM: record["pulseBPM"] as? Int
        )
    }
}
