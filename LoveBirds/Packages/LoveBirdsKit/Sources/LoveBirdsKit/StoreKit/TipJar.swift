import Foundation
import StoreKit

public enum TipProduct: String, CaseIterable, Sendable {
    case small = "com.lokei.lovebirds.tip.small"
    case medium = "com.lokei.lovebirds.tip.medium"
    case large = "com.lokei.lovebirds.tip.large"
    case generous = "com.lokei.lovebirds.tip.generous"

    public var displayPriceHint: String {
        switch self {
        case .small: return "$0.99"
        case .medium: return "$2.99"
        case .large: return "$4.99"
        case .generous: return "$9.99"
        }
    }

    public var label: String {
        switch self {
        case .small: return "Coffee"
        case .medium: return "Lunch"
        case .large: return "Date night"
        case .generous: return "Generous tip"
        }
    }

    public var emoji: String {
        switch self {
        case .small: return "☕️"
        case .medium: return "🍱"
        case .large: return "🌹"
        case .generous: return "🎁"
        }
    }
}

@MainActor
@Observable
public final class TipJar {
    public private(set) var products: [Product] = []
    public private(set) var purchaseInProgress: TipProduct?
    public var lastError: String?

    public init() {}

    public func load() async {
        do {
            let ids = TipProduct.allCases.map(\.rawValue)
            let products = try await Product.products(for: ids)
            self.products = products.sorted { $0.price < $1.price }
        } catch {
            lastError = error.localizedDescription
            AppLogger.store.error("Tip jar product load failed: \(error.localizedDescription)")
        }
    }

    public func purchase(_ tip: TipProduct) async -> Bool {
        guard let product = products.first(where: { $0.id == tip.rawValue }) else {
            lastError = "Product not loaded"
            return false
        }
        purchaseInProgress = tip
        defer { purchaseInProgress = nil }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                HeartStore.shared.incrementTipCount()
                return true
            case .userCancelled:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified(_, let error):
            throw error
        }
    }
}
