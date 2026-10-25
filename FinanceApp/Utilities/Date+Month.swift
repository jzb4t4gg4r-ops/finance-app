import Foundation

extension Date {
    var startOfMonth: Date {
        Calendar.current.dateInterval(of: .month, for: self)?.start ?? self
    }

    func addingMonths(_ value: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: value, to: self) ?? self
    }
}
