import Foundation

struct LLMProviderConfiguration: Sendable {
    var baseURL: URL
    var apiKey: String
    var model: String

    init(baseURL: URL, apiKey: String, model: String) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.model = model
    }
}

protocol LLMClient {
    func complete(prompt: String) async throws -> String
}

enum LLMClientError: Error {
    case invalidResponse
    case decodingFailed
    case notConfigured
}

struct MockLLMClient: LLMClient {
    var cannedResponse: String

    func complete(prompt: String) async throws -> String {
        cannedResponse
    }
}
