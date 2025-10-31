import Foundation

struct PortfolioSnapshot: Identifiable, Codable {
    let id: UUID
    var date: Date
    var totalBalance: Decimal
    var categoryTotals: [AssetPrimaryCategory: Decimal]

    init(
        id: UUID = UUID(),
        date: Date,
        totalBalance: Decimal,
        categoryTotals: [AssetPrimaryCategory: Decimal]
    ) {
        self.id = id
        self.date = date
        self.totalBalance = totalBalance
        self.categoryTotals = categoryTotals
    }
}

struct AssetDistribution {
    var categoryShare: [AssetPrimaryCategory: Decimal]
    var subcategoryShare: [AssetPrimaryCategory: [String: Decimal]]
}

struct AssetStatistics {
    var calculationDate: Date
    var period: AssetPeriod
    var dateRange: DateRange
    var totalBalance: Decimal
    var totalChange: Decimal
    var changeRate: Decimal?
    var distribution: AssetDistribution
    var snapshots: [PortfolioSnapshot]

    var formattedChangeRate: String {
        guard let changeRate else { return "-" }
        let number = (changeRate as NSDecimalNumber).doubleValue * 100
        return String(format: "%.2f%%", number)
    }
}
