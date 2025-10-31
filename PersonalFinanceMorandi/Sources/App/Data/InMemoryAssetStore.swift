import Foundation

final class InMemoryAssetStore: AssetStore {
    private var storage: [Asset]

    init(initialAssets: [Asset] = SampleAssetFactory.sampleAssets()) {
        self.storage = initialAssets
    }

    func loadAssets() -> [Asset] {
        storage
    }

    func saveAssets(_ assets: [Asset]) {
        storage = assets
    }
}

enum SampleAssetFactory {
    static func sampleAssets(calendar: Calendar = .current) -> [Asset] {
        let liquidDefaults = AssetPrimaryCategory.liquid.defaultSubcategories
        let fixedDefaults = AssetPrimaryCategory.fixed.defaultSubcategories
        let investmentDefaults = AssetPrimaryCategory.investment.defaultSubcategories

        let customEmergencyFund = AssetSubcategory(name: "????", isDefault: false)
        let customParkingSpot = AssetSubcategory(name: "??", isDefault: false)
        let customCrypto = AssetSubcategory(name: "????", isDefault: false)

        return [
            Asset(
                name: "??????",
                primaryCategory: .liquid,
                subcategory: liquidDefaults[2],
                balance: 86_500,
                institution: "????",
                transactions: SampleAssetFactory.recentTransactions(seed: 1, calendar: calendar)
            ),
            Asset(
                name: "??????",
                primaryCategory: .liquid,
                subcategory: liquidDefaults[0],
                balance: 23_200,
                institution: "????",
                transactions: SampleAssetFactory.recentTransactions(seed: 2, calendar: calendar)
            ),
            Asset(
                name: "??????",
                primaryCategory: .liquid,
                subcategory: customEmergencyFund,
                balance: 30_000,
                notes: "?? 6 ??????",
                transactions: SampleAssetFactory.recentTransactions(seed: 3, calendar: calendar)
            ),
            Asset(
                name: "?????",
                primaryCategory: .fixed,
                subcategory: fixedDefaults[0],
                balance: 2_800_000,
                notes: "????",
                transactions: SampleAssetFactory.annualAppreciation(seed: 4, calendar: calendar)
            ),
            Asset(
                name: "????",
                primaryCategory: .fixed,
                subcategory: customParkingSpot,
                balance: 280_000,
                notes: "??????",
                transactions: SampleAssetFactory.annualAppreciation(seed: 5, calendar: calendar)
            ),
            Asset(
                name: "??????",
                primaryCategory: .investment,
                subcategory: investmentDefaults[2],
                balance: 120_000,
                institution: "????",
                transactions: SampleAssetFactory.recentTransactions(seed: 6, calendar: calendar)
            ),
            Asset(
                name: "????",
                primaryCategory: .investment,
                subcategory: investmentDefaults[3],
                balance: 75_000,
                institution: "????",
                transactions: SampleAssetFactory.recentTransactions(seed: 7, calendar: calendar)
            ),
            Asset(
                name: "??????",
                primaryCategory: .investment,
                subcategory: customCrypto,
                balance: 15_000,
                notes: "? BTC ??",
                transactions: SampleAssetFactory.recentTransactions(seed: 8, calendar: calendar)
            )
        ].map { asset in
            var mutable = asset
            if let latest = asset.transactions.sorted(by: { $0.occurredAt > $1.occurredAt }).first {
                mutable.balance += latest.amountDelta
                mutable.lastUpdated = latest.occurredAt
            }
            return mutable
        }
    }

    private static func recentTransactions(seed: Int, calendar: Calendar) -> [AssetTransaction] {
        let now = Date()
        return (0..<6).compactMap { index -> AssetTransaction? in
            guard let date = calendar.date(byAdding: .weekOfYear, value: -index, to: now) else { return nil }
            let delta = Decimal(Double(seed * 2 - index) * 120.0).rounded(2)
            return AssetTransaction(occurredAt: date, amountDelta: delta, kind: delta >= 0 ? .inflow : .outflow)
        }
    }

    private static func annualAppreciation(seed: Int, calendar: Calendar) -> [AssetTransaction] {
        let now = Date()
        return (0..<4).compactMap { index -> AssetTransaction? in
            guard let date = calendar.date(byAdding: .month, value: -index * 3, to: now) else { return nil }
            let delta = Decimal(Double(seed) * 1_500.0).rounded(2)
            return AssetTransaction(occurredAt: date, amountDelta: delta, kind: .appreciation)
        }
    }
}

private extension Decimal {
    func rounded(_ scale: Int16) -> Decimal {
        var value = self
        var result = Decimal()
        NSDecimalRound(&result, &value, scale, .bankers)
        return result
    }
}
