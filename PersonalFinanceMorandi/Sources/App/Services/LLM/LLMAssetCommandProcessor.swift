import Foundation

struct LLMAssetCommandProcessor {
    var client: LLMClient
    var parser: AssetCommandParser = .init()

    func process(instruction: String, assets: [Asset]) async throws -> AssetCommand {
        let prompt = buildPrompt(instruction: instruction, assets: assets)
        let response = try await client.complete(prompt: prompt)
        return try parser.parse(commandJSON: response)
    }

    private func buildPrompt(instruction: String, assets: [Asset]) -> String {
        var builder = [String]()
        builder.append("?????????????????????????? JSON????????")
        builder.append("???????? JSON????????")
        builder.append("{\n  \"action\": \"add|update|delete\",\n  \"assetName\": \"string?\",\n  \"assetID\": \"uuid-string?\",\n  \"primaryCategory\": \"liquid|fixed|investment?\",\n  \"subcategoryName\": \"string?\",\n  \"amount\": number?,\n  \"delta\": number?,\n  \"institution\": \"string?\",\n  \"notes\": \"string?\"\n}")
        builder.append("amount ?????????delta ?????????")
        builder.append("???????????? assetName?primaryCategory?amount?????????? null?")
        builder.append("?????????")
        builder.append(formatAssets(assets))
        builder.append("?????\n\(instruction)")
        builder.append("???? JSON????????")
        return builder.joined(separator: "\n\n")
    }

    private func formatAssets(_ assets: [Asset]) -> String {
        if assets.isEmpty { return "?????" }
        let lines = assets.map { asset -> String in
            let amount = NSDecimalNumber(decimal: asset.balance).stringValue
            return "- id: \(asset.id.uuidString), name: \(asset.name), category: \(asset.primaryCategory.rawValue), subcategory: \(asset.subcategory.name), balance: \(amount)"
        }
        return lines.joined(separator: "\n")
    }
}
