import Foundation

struct AssetCommandParser {
    private let decoder: JSONDecoder

    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    func parse(commandJSON: String) throws -> AssetCommand {
        guard let data = commandJSON.data(using: .utf8) else {
            throw LLMClientError.decodingFailed
        }
        return try decoder.decode(AssetCommand.self, from: data)
    }
}
