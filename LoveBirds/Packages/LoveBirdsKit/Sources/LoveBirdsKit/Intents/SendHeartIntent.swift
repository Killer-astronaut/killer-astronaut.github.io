import AppIntents
import Foundation

public struct PartnerEntity: AppEntity, Identifiable, Hashable, Sendable {
    public static var typeDisplayRepresentation: TypeDisplayRepresentation { "Partner" }

    public static var defaultQuery = PartnerEntityQuery()

    public let id: UUID
    public let name: String
    public let initials: String

    public init(id: UUID, name: String, initials: String) {
        self.id = id
        self.name = name
        self.initials = initials
    }

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "Love Birds")
    }
}

public struct PartnerEntityQuery: EntityQuery {
    public init() {}

    @MainActor
    public func entities(for identifiers: [PartnerEntity.ID]) async throws -> [PartnerEntity] {
        HeartStore.shared.partners
            .filter { identifiers.contains($0.id) }
            .map { PartnerEntity(id: $0.id, name: $0.displayName, initials: $0.initials) }
    }

    @MainActor
    public func suggestedEntities() async throws -> [PartnerEntity] {
        HeartStore.shared.partners.map {
            PartnerEntity(id: $0.id, name: $0.displayName, initials: $0.initials)
        }
    }
}

public struct VibeEntity: AppEntity, Identifiable, Hashable, Sendable {
    public static var typeDisplayRepresentation: TypeDisplayRepresentation { "Vibe" }
    public static var defaultQuery = VibeEntityQuery()

    public let id: String
    public let name: String

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

public struct VibeEntityQuery: EntityQuery {
    public init() {}

    public func entities(for identifiers: [String]) async throws -> [VibeEntity] {
        HeartVibe.allCases
            .filter { identifiers.contains($0.rawValue) }
            .map { VibeEntity(id: $0.rawValue, name: $0.label) }
    }

    public func suggestedEntities() async throws -> [VibeEntity] {
        HeartVibe.allCases.map { VibeEntity(id: $0.rawValue, name: $0.label) }
    }
}

public struct SendHeartIntent: AppIntent {
    public static var title: LocalizedStringResource = "Send a Heart"
    public static var description = IntentDescription("Send an instant heart to someone you've paired with.")
    public static var openAppWhenRun = false

    @Parameter(title: "To")
    public var partner: PartnerEntity

    @Parameter(title: "Vibe")
    public var vibe: VibeEntity?

    public init() {}

    public init(partner: PartnerEntity, vibe: VibeEntity? = nil) {
        self.partner = partner
        self.vibe = vibe
    }

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = HeartStore.shared
        guard let resolvedPartner = store.partners.first(where: { $0.id == partner.id }) else {
            throw $partner.needsValueError("Pick someone to send a heart to.")
        }
        let chosenVibe = vibe.flatMap { HeartVibe(rawValue: $0.id) } ?? resolvedPartner.preferredVibe
        let heart = store.recordSent(partnerID: resolvedPartner.id, vibe: chosenVibe)
        HapticEngine.shared.play(pattern: store.pattern(id: heart.hapticPatternID))
        await SyncEngine.shared.sendHeart(heart, on: resolvedPartner)
        return .result(dialog: "Sent a \(chosenVibe.label.lowercased()) to \(resolvedPartner.displayName).")
    }
}

public struct LoveBirdsShortcuts: AppShortcutsProvider {
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SendHeartIntent(),
            phrases: [
                "Send a heart in \(.applicationName)",
                "Tap someone in \(.applicationName)"
            ],
            shortTitle: "Send a Heart",
            systemImageName: "heart.fill"
        )
    }
}
