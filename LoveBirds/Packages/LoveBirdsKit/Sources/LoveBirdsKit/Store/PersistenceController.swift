import Foundation

public final class PersistenceController: @unchecked Sendable {
    public static let shared = PersistenceController()

    public struct Snapshot: Codable, Sendable {
        public let partners: [Partner]
        public let hearts: [Heart]
        public let customPatterns: [HapticPattern]
        public let tipsGiven: Int
    }

    private let queue = DispatchQueue(label: "com.lokei.lovebirds.persistence", qos: .utility)
    private let fileURL: URL
    private let appGroupID = "group.com.lokei.lovebirds"

    public init(fileName: String = "lovebirds-snapshot.json") {
        let base: URL
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            base = groupURL
        } else {
            base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? FileManager.default.temporaryDirectory
        }
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        self.fileURL = base.appendingPathComponent(fileName)
    }

    public func loadSnapshot() -> Snapshot? {
        guard let data = try? Data(contentsOf: fileURL),
              let snap = try? JSONDecoder.lovebirds.decode(Snapshot.self, from: data) else {
            return nil
        }
        return snap
    }

    public func save(_ snapshot: Snapshot) {
        queue.async { [fileURL] in
            do {
                let data = try JSONEncoder.lovebirds.encode(snapshot)
                try data.write(to: fileURL, options: .atomic)
            } catch {
                AppLogger.store.error("Persistence save failed: \(error.localizedDescription)")
            }
        }
    }
}

public extension JSONEncoder {
    static var lovebirds: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }
}

public extension JSONDecoder {
    static var lovebirds: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
