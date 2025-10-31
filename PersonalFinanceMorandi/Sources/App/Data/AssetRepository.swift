import Foundation
import Combine

protocol AssetStore {
    func loadAssets() -> [Asset]
    func saveAssets(_ assets: [Asset]) throws
}

enum AssetRepositoryError: Error {
    case assetNotFound
}

@MainActor
final class AssetRepository: ObservableObject {
    @Published private(set) var assets: [Asset] = []

    private let store: AssetStore

    init(store: AssetStore) {
        self.store = store
        self.assets = store.loadAssets()
    }

    func refresh() {
        assets = store.loadAssets()
    }

    func addAsset(_ asset: Asset) {
        assets.append(asset)
        persist()
    }

    func updateAsset(_ asset: Asset) throws {
        guard let index = assets.firstIndex(where: { $0.id == asset.id }) else {
            throw AssetRepositoryError.assetNotFound
        }
        assets[index] = asset
        persist()
    }

    func removeAsset(_ assetID: UUID) throws {
        guard let index = assets.firstIndex(where: { $0.id == assetID }) else {
            throw AssetRepositoryError.assetNotFound
        }
        assets.remove(at: index)
        persist()
    }

    func appendTransaction(_ transaction: AssetTransaction, to assetID: UUID) throws {
        guard let index = assets.firstIndex(where: { $0.id == assetID }) else {
            throw AssetRepositoryError.assetNotFound
        }

        var asset = assets[index]
        asset.transactions.append(transaction)
        asset.balance += transaction.amountDelta
        asset.lastUpdated = transaction.occurredAt
        assets[index] = asset
        persist()
    }

    func applyBalance(_ newBalance: Decimal, to assetID: UUID) throws {
        guard let index = assets.firstIndex(where: { $0.id == assetID }) else {
            throw AssetRepositoryError.assetNotFound
        }
        assets[index].balance = newBalance
        assets[index].lastUpdated = .now
        persist()
    }

    private func persist() {
        do {
            try store.saveAssets(assets)
        } catch {
            assertionFailure("Failed to persist assets: \(error)")
        }
    }
}
