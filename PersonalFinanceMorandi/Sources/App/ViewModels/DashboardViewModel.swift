import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var selectedPeriod: AssetPeriod = .month {
        didSet { recalculate() }
    }
    @Published private(set) var statistics: AssetStatistics?

    private let repository: AssetRepository
    private let calculator: StatisticsCalculator
    private var cancellables: Set<AnyCancellable> = []

    init(repository: AssetRepository, calculator: StatisticsCalculator = StatisticsCalculator()) {
        self.repository = repository
        self.calculator = calculator
        observeAssets()
        recalculate()
    }

    func refresh() {
        repository.refresh()
    }

    func select(period: AssetPeriod) {
        selectedPeriod = period
    }

    private func observeAssets() {
        repository.$assets
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.recalculate()
            }
            .store(in: &cancellables)
    }

    private func recalculate() {
        statistics = calculator.makeStatistics(for: repository.assets, period: selectedPeriod)
    }
}
