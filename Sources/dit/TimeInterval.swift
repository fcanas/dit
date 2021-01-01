import Foundation

extension TimeInterval {
    var days: TimeInterval {
        self.hours * 24
    }
    var hours: TimeInterval {
        self.minutes * 60
    }
    var minutes: TimeInterval {
        self * 60
    }
}
