import SwiftUI

struct ContentView: View {
    @StateObject private var dashboardViewModel: DashboardViewModel
    @StateObject private var assetListViewModel: AssetListViewModel
    @StateObject private var assistantViewModel: LLMCommandViewModel

    init(repository: AssetRepository, llmProcessor: LLMAssetCommandProcessor) {
        _dashboardViewModel = StateObject(wrappedValue: DashboardViewModel(repository: repository))
        _assetListViewModel = StateObject(wrappedValue: AssetListViewModel(repository: repository))
        _assistantViewModel = StateObject(wrappedValue: LLMCommandViewModel(repository: repository, processor: llmProcessor))
    }

    var body: some View {
        TabView {
            DashboardView(viewModel: dashboardViewModel)
                .tabItem {
                    Label("??", systemImage: "chart.pie.fill")
                }

            AssetListView(viewModel: assetListViewModel)
                .tabItem {
                    Label("??", systemImage: "list.bullet.rectangle")
                }

            AssistantCommandView(viewModel: assistantViewModel)
                .tabItem {
                    Label("??", systemImage: "sparkles")
                }
        }
        .accentColor(MorandiPalette.accent)
    }
}
