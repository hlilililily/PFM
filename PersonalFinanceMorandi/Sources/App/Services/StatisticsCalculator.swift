import Foundation

struct StatisticsCalculator {
    var calendar: Calendar = .current

    func makeStatistics(
        for assets: [Asset],
        period: AssetPeriod,
        referenceDate: Date = .now
    ) -> AssetStatistics {
        let range = period.dateRange(for: referenceDate, calendar: calendar)

        let totalBalance = assets.reduce(Decimal.zero) { result, asset in
            result + asset.balance
        }

        let change = assets.reduce(Decimal.zero) { result, asset in
            result + asset.transactions
                .filter { range.contains($0.occurredAt) }
                .reduce(Decimal.zero) { $0 + $1.amountDelta }
        }

        let categoryTotals = totalsByCategory(assets: assets)
        let subcategoryTotals = totalsBySubcategory(assets: assets)

        let previousTotal = totalBalance - change
        let changeRate: Decimal?
        if previousTotal == .zero {
            changeRate = nil
        } else {
            changeRate = change / previousTotal
        }

        let distribution = AssetDistribution(
            categoryShare: distribution(from: categoryTotals, total: totalBalance),
            subcategoryShare: subcategoryDistribution(from: subcategoryTotals)
        )

        let snapshots = makeSnapshots(assets: assets, within: range, steps: 6)

        return AssetStatistics(
            calculationDate: referenceDate,
            period: period,
            dateRange: range,
            totalBalance: totalBalance,
            totalChange: change,
            changeRate: changeRate,
            distribution: distribution,
            snapshots: snapshots
        )
    }

    private func totalsByCategory(assets: [Asset]) -> [AssetPrimaryCategory: Decimal] {
        assets.reduce(into: [:]) { result, asset in
            result[asset.primaryCategory, default: .zero] += asset.balance
        }
    }

    private func totalsBySubcategory(assets: [Asset]) -> [AssetPrimaryCategory: [String: Decimal]] {
        assets.reduce(into: [:]) { result, asset in
            var subTotals = result[asset.primaryCategory, default: [:]]
            subTotals[asset.subcategory.name, default: .zero] += asset.balance
            result[asset.primaryCategory] = subTotals
        }
    }

    private func distribution(
        from categoryTotals: [AssetPrimaryCategory: Decimal],
        total: Decimal
    ) -> [AssetPrimaryCategory: Decimal] {
        guard total != .zero else { return [:] }
        return categoryTotals.mapValues { $0 / total }
    }

    private func subcategoryDistribution(
        from subcategoryTotals: [AssetPrimaryCategory: [String: Decimal]]
    ) -> [AssetPrimaryCategory: [String: Decimal]] {
        subcategoryTotals.reduce(into: [:]) { result, element in
            let (category, values) = element
            let categoryTotal = values.values.reduce(Decimal.zero, +)
            guard categoryTotal != .zero else { return }
            result[category] = values.mapValues { $0 / categoryTotal }
        }
    }

    private func makeSnapshots(assets: [Asset], within range: DateRange, steps: Int) -> [PortfolioSnapshot] {
        guard steps > 1 else { return [] }

        let interval = range.duration / Double(steps - 1)
        return (0..<steps).compactMap { step -> PortfolioSnapshot? in
            let snapshotDate = range.start.addingTimeInterval(Double(step) * interval)
            guard snapshotDate <= range.end else { return nil }
            let totals = totalsAt(date: snapshotDate, assets: assets)
            let totalBalance = totals.values.reduce(Decimal.zero, +)
            return PortfolioSnapshot(
                date: snapshotDate,
                totalBalance: totalBalance,
                categoryTotals: totals
            )
        }
    }

    private func totalsAt(date: Date, assets: [Asset]) -> [AssetPrimaryCategory: Decimal] {
        assets.reduce(into: [:]) { result, asset in
            let balanceAtDate = balance(of: asset, at: date)
            result[asset.primaryCategory, default: .zero] += balanceAtDate
        }
    }

    private func balance(of asset: Asset, at date: Date) -> Decimal {
        let relevantTransactions = asset.transactions.filter { $0.occurredAt <= date }
        let totalDelta = relevantTransactions.reduce(Decimal.zero) { $0 + $1.amountDelta }
        // Derive base by subtracting all deltas from current balance.
        let base = asset.balance - asset.transactions.reduce(Decimal.zero) { $0 + $1.amountDelta }
        return base + totalDelta
    }
}

private extension Decimal {
    static func /(lhs: Decimal, rhs: Decimal) -> Decimal {
        var lhs = lhs
        var rhs = rhs
        var result = Decimal.zero
        NSDecimalDivide(&result, &lhs, &rhs, .bankers)
        return result
    }
}
