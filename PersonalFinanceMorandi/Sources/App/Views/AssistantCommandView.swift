import SwiftUI

struct AssistantCommandView: View {
    @StateObject private var viewModel: LLMCommandViewModel
    @State private var instruction: String = ""

    init(viewModel: LLMCommandViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 16) {
            header
            TextEditor(text: $instruction)
                .padding()
                .frame(minHeight: 150)
                .background(MorandiPalette.card)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(MorandiPalette.accent.opacity(0.4), lineWidth: 1)
                )
            Button(action: send) {
                if viewModel.isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("????")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .disabled(viewModel.isProcessing || instruction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .background(viewModel.isProcessing ? MorandiPalette.accentSoft : MorandiPalette.accent)
            .cornerRadius(16)

            statusSection
            Spacer()
        }
        .padding()
        .background(MorandiPalette.background.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("????")
                .font(.largeTitle.bold())
                .foregroundColor(MorandiPalette.textPrimary)
            Text("???????????????\n?????????????? 5000?")
                .font(.subheadline)
                .foregroundColor(MorandiPalette.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let status = viewModel.statusMessage {
                Text(status)
                    .font(.subheadline)
                    .foregroundColor(status.contains("??") ? MorandiPalette.positive : MorandiPalette.negative)
            }

            if let command = viewModel.lastCommand {
                VStack(alignment: .leading, spacing: 6) {
                    Text("????")
                        .font(.headline)
                        .foregroundColor(MorandiPalette.textPrimary)
                    Text(summary(of: command))
                        .font(.caption)
                        .foregroundColor(MorandiPalette.textSecondary)
                }
                .padding()
                .background(MorandiPalette.card)
                .cornerRadius(16)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func send() {
        let trimmed = instruction.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        Task {
            await viewModel.handleInstruction(trimmed)
        }
    }

    private func summary(of command: AssetCommand) -> String {
        switch command.action {
        case .add:
            return "?????\(command.assetName ?? "??"), ?? \(command.amount.map { "\($0)" } ?? "-")"
        case .update:
            return "?????\(command.assetName ?? command.assetID?.uuidString ?? "??")"
        case .delete:
            return "?????\(command.assetName ?? command.assetID?.uuidString ?? "??")"
        }
    }
}
