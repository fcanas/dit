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
    
    @Option(name: .shortAndLong, help: "The interval in days. Matches due dates in the future and completion date in the past.")
    var days: Int = 1
    
    @Option(name: .shortAndLong, help: "The interval in hours. Matches due dates in the future and completion date in the past.")
    var hours: Int = 0
    
    @Option(name: .shortAndLong, help: "The interval in minutes. Matches due dates in the future and completion date in the past.")
    var minutes: Int = 0
    
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
        
        let searchInterval = TimeInterval(days).days + TimeInterval(hours).hours + TimeInterval(minutes).minutes
        
        let predicate: NSPredicate
        
        switch scope {
        case .all:
            predicate = store.predicateForReminders(in: [targetCalendar])
        case .complete:
            predicate = store.predicateForCompletedReminders(withCompletionDateStarting: Date().addingTimeInterval(-searchInterval), ending: Date(), calendars: [targetCalendar])
        case .incomplete:
            // Date()
            // Date().addingTimeInterval(searchInterval)
            predicate = store.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: [targetCalendar])
        }
        
        let reminders = store.sync.fetchReminders(matching: predicate)
        reminders.forEach({ (reminder) in
            print("[\(reminder.isCompleted ? "✓" : "-")] \(reminder.title ?? "")")
        })
    }
}
