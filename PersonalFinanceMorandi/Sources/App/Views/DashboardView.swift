import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel

    init(viewModel: DashboardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                periodSelector
                if let stats = viewModel.statistics {
                    totalCard(statistics: stats)
                    distributionSection(statistics: stats)
                    historySection(statistics: stats)
                } else {
                    ProgressView()
                }
            }
            .padding()
        }
        .background(MorandiPalette.background.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("????")
                .font(.largeTitle.bold())
                .foregroundColor(MorandiPalette.textPrimary)
            Text("??????????")
                .font(.subheadline)
                .foregroundColor(MorandiPalette.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var periodSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(AssetPeriod.presets, id: \.id) { period in
                    Button {
                        viewModel.select(period: period)
                    } label: {
                        Text(period.title)
                            .font(.subheadline.bold())
                            .foregroundColor(viewModel.selectedPeriod == period ? .white : MorandiPalette.textPrimary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(viewModel.selectedPeriod == period ? MorandiPalette.accent : MorandiPalette.card)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    private func totalCard(statistics: AssetStatistics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("?????")
                .font(.headline)
                .foregroundColor(MorandiPalette.textSecondary)
            Text(Self.currencyFormatter.string(from: statistics.totalBalance as NSDecimalNumber) ?? "-")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(MorandiPalette.textPrimary)
            HStack(spacing: 12) {
                Label {
                    Text("?? \(Self.deltaFormatter.string(from: statistics.totalChange as NSDecimalNumber) ?? "0")")
                } icon: {
                    Image(systemName: statistics.totalChange >= 0 ? "arrow.up" : "arrow.down")
                }
                .foregroundColor(statistics.totalChange >= 0 ? MorandiPalette.positive : MorandiPalette.negative)

                Text("?? \(statistics.formattedChangeRate)")
                    .foregroundColor(MorandiPalette.textSecondary)
            }
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(LinearGradient.morandiCard)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 8)
    }

    private func distributionSection(statistics: AssetStatistics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("????")
                .font(.headline)
                .foregroundColor(MorandiPalette.textPrimary)
            VStack(spacing: 16) {
                ForEach(statistics.distribution.categoryShare.sorted(by: { $0.key.rawValue < $1.key.rawValue }), id: \.key) { item in
                    categoryRow(category: item.key, share: item.value, subtotal: statistics.distribution.subcategoryShare[item.key] ?? [:])
                }
            }
            .padding()
            .background(MorandiPalette.card)
            .cornerRadius(16)
        }
    }

    private func categoryRow(category: AssetPrimaryCategory, share: Decimal, subtotal: [String: Decimal]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category.displayName)
                    .font(.subheadline.bold())
                    .foregroundColor(MorandiPalette.textPrimary)
                Spacer()
                Text(Self.percentFormatter.string(from: share as NSDecimalNumber) ?? "0%")
                    .foregroundColor(MorandiPalette.textSecondary)
            }
            GeometryReader { geometry in
                Capsule()
                    .fill(MorandiPalette.accent.opacity(0.4))
                    .overlay(
                        Capsule()
                            .fill(MorandiPalette.accent)
                            .frame(width: geometry.size.width * CGFloat(min(max(share.asDouble, 0), 1)))
                    )
            }
            .frame(height: 8)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(subtotal.keys.sorted(), id: \.self) { name in
                    let value = subtotal[name] ?? .zero
                    HStack {
                        Text(name)
                            .font(.caption)
                            .foregroundColor(MorandiPalette.textSecondary)
                        Spacer()
                        Text(Self.percentFormatter.string(from: value as NSDecimalNumber) ?? "0%")
                            .font(.caption)
                            .foregroundColor(MorandiPalette.textSecondary)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func historySection(statistics: AssetStatistics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("????")
                .font(.headline)
                .foregroundColor(MorandiPalette.textPrimary)

            if statistics.snapshots.isEmpty {
                Text("??????")
                    .font(.subheadline)
                    .foregroundColor(MorandiPalette.textSecondary)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(statistics.snapshots) { snapshot in
                        HStack {
                            Text(Self.dateFormatter.string(from: snapshot.date))
                                .font(.caption)
                                .foregroundColor(MorandiPalette.textSecondary)
                            Spacer()
                            Text(Self.currencyFormatter.string(from: snapshot.totalBalance as NSDecimalNumber) ?? "-")
                                .font(.caption)
                                .foregroundColor(MorandiPalette.textPrimary)
                        }
                        .padding(.vertical, 4)
                        Divider().background(MorandiPalette.accentSoft)
                    }
                }
                .padding()
                .background(MorandiPalette.card)
                .cornerRadius(16)
            }
        }
    }

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    private static let deltaFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.positivePrefix = "+"
        return formatter
    }()

    private static let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        return formatter
    }()
}

private extension Decimal {
    var asDouble: Double {
        (self as NSDecimalNumber).doubleValue
    }
}
