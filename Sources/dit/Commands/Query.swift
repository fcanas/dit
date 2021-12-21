import AppKit
import ArgumentParser
import EventKit
import libDit

struct Query: ParsableCommand {
    
    static var configuration: CommandConfiguration =
        CommandConfiguration(abstract: "Show Reminders.",
                             discussion: "Date filters \("--starting".bold) and \("--ending".bold) operate on the due date for incomplete tasks and the completion date for complete tasks.")
    
    enum Scope: String, EnumerableFlag {
        case all
        case complete
        case incomplete
    }
    
    @Flag(exclusivity: .exclusive, help: "Show Reminders based on completion status.")
    var scope: Scope = .incomplete
    
    @Option(name: .shortAndLong, help: "The name of the list to query. Default can be set with the \(Configure._commandName.bold) command.")
    var list: String?
    
    @Option(name: .shortAndLong, help: "Beginning of time range to query within, specified relative to today. e.g. \("2d".bold) specifies to search for Reminders beginning two days from now.", transform: Interval.init)
    var starting: Interval?
    
    @Option(name: .shortAndLong, help: "End of time range to query within, specified relative to today. e.g. \("3w".bold) specifies to search for Reminders before three weeks from now.", transform: Interval.init)
    var ending: Interval?
    
    func run() throws {
        
        let aa = NSWorkspace.shared.runningApplications
        
        
        let configuration = Configuration()
        
        let store = EKEventStore()
        try store.sync.authorize()
        
        let calendars = store.calendars(for: .reminder)
        
        guard let targetList = list ?? configuration.targetList else {
            throw "No default List to query. Specify one with \("--list".bold), or set a default with the configure command."
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
        
        let f = DateFormatter()
        f.dateStyle = .medium
        reminders.forEach({ (reminder) in
            let dateOut: String
            if let date = reminder.dueDateComponents?.date {
                dateOut = " - \(f.string(from: date))"
            } else {
                dateOut = ""
            }
            print("\(reminder.lineDescription)\(dateOut)")
        })
    }
}
