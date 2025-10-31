import Foundation
import Combine

struct AssetSection: Identifiable {
    let category: AssetPrimaryCategory
    var assets: [Asset]

    var id: String { category.rawValue }

    var totalBalance: Decimal {
        assets.reduce(Decimal.zero) { $0 + $1.balance }
    }
}

@MainActor
final class AssetListViewModel: ObservableObject {
    @Published private(set) var sections: [AssetSection] = []
    @Published private(set) var totalBalance: Decimal = .zero

    private let repository: AssetRepository
    private var cancellables: Set<AnyCancellable> = []

    init(repository: AssetRepository) {
        self.repository = repository
        observeAssets()
        rebuildSections(from: repository.assets)
    }

    func availableSubcategories(for category: AssetPrimaryCategory) -> [AssetSubcategory] {
        let custom = repository.assets
            .filter { $0.primaryCategory == category }
            .map { $0.subcategory }
            .filter { !$0.isDefault }
        let defaults = category.defaultSubcategories
        let combined = defaults + custom
        let uniqueByName = combined.reduce(into: [String: AssetSubcategory]()) { partialResult, subcategory in
            if partialResult[subcategory.name] == nil {
                partialResult[subcategory.name] = subcategory
            }
        }
        return uniqueByName.values.sorted { $0.name < $1.name }
    }

    func addAsset(name: String, category: AssetPrimaryCategory, subcategoryName: String, balance: Decimal, notes: String? = nil) {
        let subcategory = findOrCreateSubcategory(name: subcategoryName, category: category)
        let asset = Asset(
            name: name,
            primaryCategory: category,
            subcategory: subcategory,
            balance: balance,
            notes: notes
        )
        repository.addAsset(asset)
    }

    func updateAsset(_ asset: Asset) {
        try? repository.updateAsset(asset)
    }

    func deleteAsset(id: UUID) {
        try? repository.removeAsset(id)
    }

    func makeDetailViewModel(for asset: Asset) -> AssetDetailViewModel {
        AssetDetailViewModel(asset: asset, repository: repository)
    }

    private func observeAssets() {
        repository.$assets
            .receive(on: DispatchQueue.main)
            .sink { [weak self] assets in
                self?.rebuildSections(from: assets)
            }
            .store(in: &cancellables)
    }

    private func rebuildSections(from assets: [Asset]) {
        let grouped = Dictionary(grouping: assets, by: { $0.primaryCategory })
        sections = grouped.keys.sorted { $0.rawValue < $1.rawValue }.map { key in
            AssetSection(category: key, assets: grouped[key] ?? [])
        }
        totalBalance = assets.reduce(Decimal.zero) { $0 + $1.balance }
    }

    private func findOrCreateSubcategory(name: String, category: AssetPrimaryCategory) -> AssetSubcategory {
        if let match = availableSubcategories(for: category).first(where: { $0.name == name }) {
            return match
        }
        return AssetSubcategory(name: name, isDefault: false)
    }
}
