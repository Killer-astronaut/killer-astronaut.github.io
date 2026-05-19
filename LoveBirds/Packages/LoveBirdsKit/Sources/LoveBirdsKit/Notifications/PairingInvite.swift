import Foundation

public struct PairingInvite: Codable, Hashable, Sendable {
    public let inviteID: UUID
    public let inviterName: String
    public let inviterInitials: String
    public let colorHex: String
    public let shareURL: URL
    public let createdAt: Date

    public init(inviteID: UUID = UUID(), inviterName: String, inviterInitials: String, colorHex: String, shareURL: URL, createdAt: Date = .now) {
        self.inviteID = inviteID
        self.inviterName = inviterName
        self.inviterInitials = inviterInitials
        self.colorHex = colorHex
        self.shareURL = shareURL
        self.createdAt = createdAt
    }

    public func encoded() -> String? {
        guard let data = try? JSONEncoder.lovebirds.encode(self) else { return nil }
        return data.base64EncodedString()
    }

    public static func decode(_ token: String) -> PairingInvite? {
        guard let data = Data(base64Encoded: token),
              let invite = try? JSONDecoder.lovebirds.decode(PairingInvite.self, from: data) else {
            return nil
        }
        return invite
    }

    public var universalURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "getlokei.com"
        components.path = "/lovebirds/pair"
        components.queryItems = [URLQueryItem(name: "t", value: encoded() ?? "")]
        return components.url ?? shareURL
    }
}
