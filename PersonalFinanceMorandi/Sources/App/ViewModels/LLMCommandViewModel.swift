import Foundation

@MainActor
final class LLMCommandViewModel: ObservableObject {
    @Published private(set) var lastCommand: AssetCommand?
    @Published private(set) var statusMessage: String?
    @Published var isProcessing: Bool = false

    private let repository: AssetRepository
    private var processor: LLMAssetCommandProcessor

    init(repository: AssetRepository, processor: LLMAssetCommandProcessor) {
        self.repository = repository
        self.processor = processor
    }

    func handleInstruction(_ instruction: String) async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            let command = try await processor.process(instruction: instruction, assets: repository.assets)
            try apply(command: command)
            lastCommand = command
            statusMessage = "????"
        } catch {
            statusMessage = "????: \(error.localizedDescription)"
        }
    }

    private func apply(command: AssetCommand) throws {
        switch command.action {
        case .add:
            try handleAdd(command: command)
        case .update:
            try handleUpdate(command: command)
        case .delete:
            try handleDelete(command: command)
        }
    }

    private func handleAdd(command: AssetCommand) throws {
        guard
            let name = command.assetName,
            let category = command.primaryCategory,
            let amount = command.amount
        else {
            throw LLMClientError.invalidResponse
        }

        let subcategoryName = command.subcategoryName ?? category.defaultSubcategories.first?.name ?? "???"
        let subcategory = AssetSubcategory(name: subcategoryName, isDefault: false)
        let asset = Asset(
            name: name,
            primaryCategory: category,
            subcategory: subcategory,
            balance: amount,
            institution: command.institution,
            notes: command.notes
        )
        repository.addAsset(asset)
    }

    private func handleUpdate(command: AssetCommand) throws {
        guard let name = command.assetName else {
            throw LLMClientError.invalidResponse
        }

        guard let assetIndex = repository.assets.firstIndex(where: { $0.name == name || $0.id == command.assetID }) else {
            throw AssetRepositoryError.assetNotFound
        }

        var asset = repository.assets[assetIndex]

        if let amount = command.amount {
            asset.balance = amount
        }

        if let delta = command.delta {
            let transaction = AssetTransaction(occurredAt: .now, amountDelta: delta, kind: delta >= 0 ? .inflow : .outflow, note: command.notes)
            try repository.appendTransaction(transaction, to: asset.id)
            if let refreshed = repository.assets.first(where: { $0.id == asset.id }) {
                asset = refreshed
            }
        }

        if let category = command.primaryCategory {
            asset.primaryCategory = category
        }

        if let subcategoryName = command.subcategoryName {
            asset.subcategory = AssetSubcategory(name: subcategoryName, isDefault: false)
        }

        if let institution = command.institution {
            asset.institution = institution
        }

        if let notes = command.notes {
            asset.notes = notes
        }

        try repository.updateAsset(asset)
    }

    private func handleDelete(command: AssetCommand) throws {
        guard
            let identifier = command.assetID ?? repository.assets.first(where: { $0.name == command.assetName })?.id
        else {
            throw AssetRepositoryError.assetNotFound
        }
        try repository.removeAsset(identifier)
    }
}
