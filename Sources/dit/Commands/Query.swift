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
    var dueIn: Interval?
    
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
        
        let predicate: NSPredicate
        
        switch scope {
        case .all:
            predicate = store.predicateForReminders(in: [targetCalendar])
        case .complete:
            predicate = store.predicateForCompletedReminders(withCompletionDateStarting: nil, ending: nil, calendars: [targetCalendar])
        case .incomplete:
            let ending: Date? = nil
//            if let interval = dueIn {
//                ending = Date().addingTimeInterval(interval.timeInterval)
//            }
            predicate = store.predicateForIncompleteReminders(withDueDateStarting: nil, ending: ending, calendars: [targetCalendar])
        }
        
        let reminders = store.sync.fetchReminders(matching: predicate)
        reminders.forEach({ (reminder) in
            print("[\(reminder.isCompleted ? "✓" : "-")] \(reminder.title ?? "")")
        })
    }
}
