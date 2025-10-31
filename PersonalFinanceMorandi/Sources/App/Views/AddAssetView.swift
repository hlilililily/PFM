import SwiftUI

struct AddAssetView: View {
    @ObservedObject var viewModel: AssetListViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var category: AssetPrimaryCategory = .liquid
    @State private var subcategoryName: String = ""
    @State private var amountText: String = ""
    @State private var notes: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("????")) {
                    TextField("????", text: $name)
                    Picker("??", selection: $category) {
                        ForEach(AssetPrimaryCategory.allCases) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                    Picker("??", selection: $subcategoryName) {
                        ForEach(availableSubcategories, id: \.self) { item in
                            Text(item).tag(item)
                        }
                    }
                }

                Section(header: Text("??")) {
                    TextField("????", text: $amountText)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("??")) {
                    TextField("??", text: $notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle("????")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("??") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("??") { save() }
                        .disabled(!canSave)
                }
            }
            .onChange(of: category) { _ in
                if !availableSubcategories.contains(subcategoryName) {
                    subcategoryName = availableSubcategories.first ?? ""
                }
            }
            .onAppear {
                if subcategoryName.isEmpty {
                    subcategoryName = availableSubcategories.first ?? ""
                }
            }
        }
    }

    private var availableSubcategories: [String] {
        viewModel.availableSubcategories(for: category).map(\.name)
    }

    private var canSave: Bool {
        !name.isEmpty && !subcategoryName.isEmpty && Decimal(string: amountText) != nil
    }

    private func save() {
        guard let amount = Decimal(string: amountText) else { return }
        viewModel.addAsset(name: name, category: category, subcategoryName: subcategoryName, balance: amount, notes: notes.isEmpty ? nil : notes)
        dismiss()
    }
}
