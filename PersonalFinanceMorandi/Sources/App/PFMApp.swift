import SwiftUI

@main
struct PFMApp: App {
    @StateObject private var repository: AssetRepository
    private let llmProcessor: LLMAssetCommandProcessor

    init() {
        let store = InMemoryAssetStore()
        let repo = AssetRepository(store: store)
        _repository = StateObject(wrappedValue: repo)
        llmProcessor = LLMAssetCommandProcessor(client: RuleBasedLLMClient())
    }

    var body: some Scene {
        WindowGroup {
            ContentView(repository: repository, llmProcessor: llmProcessor)
                .preferredColorScheme(.light)
        }
    }
}
