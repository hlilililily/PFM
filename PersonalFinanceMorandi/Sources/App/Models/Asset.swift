import Foundation

struct Asset: Identifiable, Codable {
    let id: UUID
    var name: String
    var primaryCategory: AssetPrimaryCategory
    var subcategory: AssetSubcategory
    var balance: Decimal
    var currencyCode: String
    var institution: String?
    var notes: String?
    var lastUpdated: Date
    var transactions: [AssetTransaction]

    init(
        id: UUID = UUID(),
        name: String,
        primaryCategory: AssetPrimaryCategory,
        subcategory: AssetSubcategory,
        balance: Decimal,
        currencyCode: String = "CNY",
        institution: String? = nil,
        notes: String? = nil,
        lastUpdated: Date = .now,
        transactions: [AssetTransaction] = []
    ) {
        self.id = id
        self.name = name
        self.primaryCategory = primaryCategory
        self.subcategory = subcategory
        self.balance = balance
        self.currencyCode = currencyCode
        self.institution = institution
        self.notes = notes
        self.lastUpdated = lastUpdated
        self.transactions = transactions
    }
}

struct AssetTransaction: Identifiable, Codable {
    enum Kind: String, Codable {
        case adjustment
        case inflow
        case outflow
        case appreciation
        case depreciation
    }

    let id: UUID
    var occurredAt: Date
    var amountDelta: Decimal
    var kind: Kind
    var note: String?

    init(
        id: UUID = UUID(),
        occurredAt: Date,
        amountDelta: Decimal,
        kind: Kind = .adjustment,
        note: String? = nil
    ) {
        self.id = id
        self.occurredAt = occurredAt
        self.amountDelta = amountDelta
        self.kind = kind
        self.note = note
    }
}
