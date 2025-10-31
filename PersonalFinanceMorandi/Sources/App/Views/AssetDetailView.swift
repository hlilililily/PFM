import SwiftUI

struct AssetDetailView: View {
    @StateObject private var viewModel: AssetDetailViewModel
    @State private var balanceText: String = ""
    @State private var deltaText: String = ""
    @State private var noteText: String = ""

    init(viewModel: AssetDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _balanceText = State(initialValue: viewModel.asset.balance.description)
    }

    var body: some View {
        Form {
            Section(header: Text("????")) {
                HStack {
                    Text("??")
                    Spacer()
                    Text(viewModel.asset.name)
                        .foregroundColor(MorandiPalette.textSecondary)
                }
                HStack {
                    Text("??")
                    Spacer()
                    Text(viewModel.asset.primaryCategory.displayName)
                        .foregroundColor(MorandiPalette.textSecondary)
                }
                HStack {
                    Text("??")
                    Spacer()
                    Text(viewModel.asset.subcategory.name)
                        .foregroundColor(MorandiPalette.textSecondary)
                }
                if let institution = viewModel.asset.institution {
                    HStack {
                        Text("??")
                        Spacer()
                        Text(institution)
                            .foregroundColor(MorandiPalette.textSecondary)
                    }
                }
            }

            Section(header: Text("????")) {
                TextField("????", text: $balanceText)
                    .keyboardType(.decimalPad)
                Button("????") {
                    guard let amount = Decimal(string: balanceText) else { return }
                    viewModel.updateBalance(amount)
                }
            }

            Section(header: Text("????")) {
                TextField("????", text: $deltaText)
                    .keyboardType(.decimalPad)
                TextField("??", text: $noteText)
                Button("????") {
                    guard let delta = Decimal(string: deltaText) else { return }
                    let kind: AssetTransaction.Kind = delta >= 0 ? .inflow : .outflow
                    viewModel.applyDelta(delta, note: noteText.isEmpty ? nil : noteText, kind: kind)
                    deltaText = ""
                    noteText = ""
                }
            }

            Section(header: Text("????")) {
                if viewModel.asset.transactions.isEmpty {
                    Text("????")
                        .foregroundColor(MorandiPalette.textSecondary)
                } else {
                    ForEach(viewModel.asset.transactions.sorted(by: { $0.occurredAt > $1.occurredAt })) { transaction in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(Self.dateFormatter.string(from: transaction.occurredAt))
                                    .font(.caption)
                                    .foregroundColor(MorandiPalette.textSecondary)
                                Spacer()
                                Text(Self.deltaFormatter.string(from: transaction.amountDelta as NSDecimalNumber) ?? "")
                                    .font(.body.bold())
                                    .foregroundColor(transaction.amountDelta >= 0 ? MorandiPalette.positive : MorandiPalette.negative)
                            }
                            if let note = transaction.note, !note.isEmpty {
                                Text(note)
                                    .font(.caption)
                                    .foregroundColor(MorandiPalette.textSecondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle(viewModel.asset.name)
        .onChange(of: viewModel.asset.balance) { newValue in
            balanceText = newValue.description
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let deltaFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.positivePrefix = "+"
        return formatter
    }()
}
