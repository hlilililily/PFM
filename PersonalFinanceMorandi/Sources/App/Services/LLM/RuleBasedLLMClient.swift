import Foundation

struct RuleBasedLLMClient: LLMClient {
    func complete(prompt: String) async throws -> String {
        guard let instruction = prompt.components(separatedBy: "?????").last?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "???? JSON").first?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        else {
            throw LLMClientError.invalidResponse
        }

        let command = interpret(instruction: instruction)
        let data = try JSONEncoder().encode(command)
        guard let json = String(data: data, encoding: .utf8) else {
            throw LLMClientError.decodingFailed
        }
        return json
    }

    private func interpret(instruction: String) -> AssetCommand {
        let lower = instruction.lowercased()

        if lower.contains("??") || lower.contains("??") {
            let name = extractName(from: instruction)
            return AssetCommand(action: .delete, assetName: name)
        }

        if lower.contains("??") || lower.contains("??") {
            let name = extractName(from: instruction)
            let amount = extractAmount(from: instruction)
            let category = extractCategory(from: instruction)
            return AssetCommand(
                action: .add,
                assetName: name ?? "???",
                primaryCategory: category,
                amount: amount,
                notes: instruction
            )
        }

        let name = extractName(from: instruction)
        let delta = extractDelta(from: instruction)
        let amount = extractAmount(from: instruction)
        return AssetCommand(
            action: .update,
            assetName: name,
            amount: amount,
            delta: delta,
            notes: instruction
        )
    }

    private func extractName(from instruction: String) -> String? {
        let markers = ["?", "?", "?", "?", "?"]
        for marker in markers {
            if let range = instruction.range(of: marker) {
                let substring = instruction[range.upperBound...]
                if let balanceRange = substring.range(of: "??") {
                    let name = substring[..<balanceRange.lowerBound]
                    return name.trimmingCharacters(in: .whitespaces)
                }
            }
        }
        return nil
    }

    private func extractAmount(from instruction: String) -> Decimal? {
        guard let match = instruction.firstMatch(of: /([0-9]+(?:\.[0-9]+)?)(?:\s*?|\s*?|\s*???)?/)
        else { return nil }
        let numberString = String(match.1)
        if instruction.contains("?") {
            return (Decimal(string: numberString) ?? .zero) * 10_000
        }
        return Decimal(string: numberString)
    }

    private func extractDelta(from instruction: String) -> Decimal? {
        guard let amount = extractAmount(from: instruction) else { return nil }
        if instruction.contains("??") || instruction.contains("??") || instruction.contains("??") {
            return -amount
        }
        if instruction.contains("??") || instruction.contains("??") || instruction.contains("??") {
            return amount
        }
        return nil
    }

    private func extractCategory(from instruction: String) -> AssetPrimaryCategory? {
        if instruction.contains("??") || instruction.contains("??") || instruction.contains("??") {
            return .investment
        }
        if instruction.contains("?") || instruction.contains("?") {
            return .fixed
        }
        if instruction.contains("???") || instruction.contains("??") || instruction.contains("??") || instruction.contains("???") {
            return .liquid
        }
        return nil
    }
}
