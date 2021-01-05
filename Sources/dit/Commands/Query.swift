import ArgumentParser
import EventKit

struct Query: ParsableCommand {
    
    enum Scope: String, EnumerableFlag {
        case all
        case complete
        case incomplete
    }
    
    @Flag(exclusivity: .exclusive, help: "Show completed reminders.")
    var scope: Scope = .incomplete
    
    @Option(name: .shortAndLong, help: "The list to query. Default can be set with the configure command.")
    var list: String?
    
    @Option(name: .shortAndLong, help: "", transform: Interval.init)
    var starting: Interval?
    
    @Option(name: .shortAndLong, help: "", transform: Interval.init)
    var ending: Interval?
    
    func run() throws {
        let configuration = Configuration()
        
        let store = EKEventStore()
        try store.sync.authorize()
        
        let calendars = store.calendars(for: .reminder)
        
        guard let targetList = list ?? configuration.targetList else {
            throw "No target list to query. Specify one with --list, or set a default with the configure command."
        }
        guard let targetCalendar = calendars.first(where: { $0.title == targetList }) else {
            throw "No list named \(targetList) found."
        }
        
        var predicates: [NSPredicate] = []
        
        func asDate(_ interval: Interval) -> Date? {
            return Calendar.current.date(byAdding: interval.dateComponents, to: Date())
        }
        let start = starting.flatMap(asDate)
        let end = ending.flatMap(asDate)
        
        switch scope {
        case .all:
            predicates.append(store.predicateForCompletedReminders(withCompletionDateStarting: start, ending: end, calendars: [targetCalendar]))
            predicates.append(store.predicateForIncompleteReminders(withDueDateStarting: start, ending: end, calendars: [targetCalendar]))
        case .complete:
            predicates.append(store.predicateForCompletedReminders(withCompletionDateStarting: start, ending: end, calendars: [targetCalendar]))
        case .incomplete:
            predicates.append(store.predicateForIncompleteReminders(withDueDateStarting: start, ending: end, calendars: [targetCalendar]))
        }
        
        let reminders = predicates.flatMap { store.sync.fetchReminders(matching: $0) }
        reminders.forEach({ (reminder) in
            print("[\(reminder.isCompleted ? "✓" : "-")] \(reminder.title ?? "")")
        })
    }
}
