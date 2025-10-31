import Foundation
import Combine

@MainActor
final class AssetDetailViewModel: ObservableObject {
    @Published var asset: Asset

    private let repository: AssetRepository
    private var cancellables: Set<AnyCancellable> = []

    init(asset: Asset, repository: AssetRepository) {
        self.asset = asset
        self.repository = repository
        bindRepository()
    }

    func saveChanges() {
        try? repository.updateAsset(asset)
    }

    func applyDelta(_ delta: Decimal, note: String? = nil, occurredAt: Date = .now, kind: AssetTransaction.Kind = .adjustment) {
        let transaction = AssetTransaction(occurredAt: occurredAt, amountDelta: delta, kind: kind, note: note)
        try? repository.appendTransaction(transaction, to: asset.id)
    }

    func updateBalance(_ newBalance: Decimal) {
        try? repository.applyBalance(newBalance, to: asset.id)
    }

    func deleteAsset() {
        try? repository.removeAsset(asset.id)
    }

    private func bindRepository() {
        repository.$assets
            .compactMap { assets in assets.first(where: { $0.id == self.asset.id }) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] latest in
                self?.asset = latest
            }
            .store(in: &cancellables)
    }
}
