import Foundation

enum AssetPeriod: Equatable, Identifiable {
    case week
    case month
    case year
    case custom(DateRange)

    var id: String {
        switch self {
        case .week: return "week"
        case .month: return "month"
        case .year: return "year"
        case .custom(let range):
            return "custom-\(range.start.timeIntervalSince1970)-\(range.end.timeIntervalSince1970)"
        }
    }

    var title: String {
        switch self {
        case .week: return "????"
        case .month: return "????"
        case .year: return "????"
        case .custom: return "???"
        }
    }

    func dateRange(for referenceDate: Date = .now, calendar: Calendar = .current) -> DateRange {
        switch self {
        case .week:
            let start = calendar.dateInterval(of: .weekOfYear, for: referenceDate)?.start ?? referenceDate
            return DateRange(start: start, end: referenceDate)
        case .month:
            let start = calendar.dateInterval(of: .month, for: referenceDate)?.start ?? referenceDate
            return DateRange(start: start, end: referenceDate)
        case .year:
            let start = calendar.dateInterval(of: .year, for: referenceDate)?.start ?? referenceDate
            return DateRange(start: start, end: referenceDate)
        case .custom(let range):
            return range
        }
    }

    static var presets: [AssetPeriod] {
        [.week, .month, .year]
    }
}
