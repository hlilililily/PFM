import SwiftUI

struct AssetListView: View {
    @StateObject private var viewModel: AssetListViewModel
    @State private var presentingAddSheet = false

    init(viewModel: AssetListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("???")
                            .font(.subheadline)
                            .foregroundColor(MorandiPalette.textSecondary)
                        Spacer()
                        Text(Self.currencyFormatter.string(from: viewModel.totalBalance as NSDecimalNumber) ?? "-")
                            .font(.headline)
                            .foregroundColor(MorandiPalette.textPrimary)
                    }
                    .padding(.vertical, 8)
                }

                ForEach(viewModel.sections) { section in
                    Section(header: Text(section.category.displayName).foregroundColor(MorandiPalette.textSecondary)) {
                        ForEach(section.assets) { asset in
                            NavigationLink(destination: AssetDetailView(viewModel: viewModel.makeDetailViewModel(for: asset))) {
                                AssetRow(asset: asset)
                            }
                            .listRowBackground(MorandiPalette.card.opacity(0.4))
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(MorandiPalette.background)
            .navigationTitle("????")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        presentingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $presentingAddSheet) {
            AddAssetView(viewModel: viewModel)
        }
    }

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

private struct AssetRow: View {
    let asset: Asset

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(asset.name)
                    .font(.headline)
                    .foregroundColor(MorandiPalette.textPrimary)
                Spacer()
                Text(currencyFormatter.string(from: asset.balance as NSDecimalNumber) ?? "-")
                    .font(.subheadline)
                    .foregroundColor(MorandiPalette.textPrimary)
            }
            HStack(spacing: 12) {
                Label(asset.primaryCategory.displayName, systemImage: "square.grid.2x2")
                Label(asset.subcategory.name, systemImage: "tag")
                if let institution = asset.institution {
                    Label(institution, systemImage: "building.2")
                }
            }
            .font(.caption)
            .foregroundColor(MorandiPalette.textSecondary)
        }
        .padding(.vertical, 8)
    }

    private var currencyFormatter: NumberFormatter {
        Self.currencyFormatter
    }

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
