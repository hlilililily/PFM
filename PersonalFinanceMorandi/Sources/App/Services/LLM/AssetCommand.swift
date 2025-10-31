import Foundation

enum AssetCommandAction: String, Codable {
    case add
    case update
    case delete
}

struct AssetCommand: Codable {
    var action: AssetCommandAction
    var assetName: String?
    var assetID: UUID?
    var primaryCategory: AssetPrimaryCategory?
    var subcategoryName: String?
    var amount: Decimal?
    var delta: Decimal?
    var institution: String?
    var notes: String?

    init(
        action: AssetCommandAction,
        assetName: String? = nil,
        assetID: UUID? = nil,
        primaryCategory: AssetPrimaryCategory? = nil,
        subcategoryName: String? = nil,
        amount: Decimal? = nil,
        delta: Decimal? = nil,
        institution: String? = nil,
        notes: String? = nil
    ) {
        self.action = action
        self.assetName = assetName
        self.assetID = assetID
        self.primaryCategory = primaryCategory
        self.subcategoryName = subcategoryName
        self.amount = amount
        self.delta = delta
        self.institution = institution
        self.notes = notes
    }
}
