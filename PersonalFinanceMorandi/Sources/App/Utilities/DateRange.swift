import Foundation

struct DateRange: Equatable, Hashable {
    var start: Date
    var end: Date

    init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }

    static func since(_ date: Date) -> DateRange {
        DateRange(start: date, end: .now)
    }

    var duration: TimeInterval {
        end.timeIntervalSince(start)
    }

    func contains(_ date: Date) -> Bool {
        (start ... end).contains(date)
    }

    func intersects(_ other: DateRange) -> Bool {
        other.end >= start && other.start <= end
    }
}
