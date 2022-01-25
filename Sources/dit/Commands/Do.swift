import ArgumentParser
import EventKit
import libDit
import OSLog

struct Do: ParsableCommand {
    
    static var configuration: CommandConfiguration =
    CommandConfiguration(abstract: "Mark reminders as done.",
                         discussion: "Do is an interactive command.The flags and options form a query, and present a numbered list of items that can be selected for toggling. Date filters --\(CodingKeys.starting.stringValue.bold) and --\(CodingKeys.ending.stringValue.bold) operate on the due date for incomplete tasks and the completion date for complete tasks.")
    
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
        
        let configuration = Configuration()
        
        let store = EKEventStore()
        try store.sync.authorize()
        
        let calendars = store.calendars(for: .reminder)
        
        guard let targetList = list ?? configuration.targetList else {
            throw "No default List to query. Specify one with --\(CodingKeys.list.stringValue.bold), or set a default with the configure command."
        }
        guard let targetCalendar = calendars.first(where: { $0.title == targetList }) else {
            throw "No list named \(targetList) found."
        }
        
        guard targetCalendar.allowsContentModifications else {
            throw "You are not allowed to make changes in \(targetCalendar.title)"
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
        
        reminders.enumerated().forEach({ (reminder) in
            let dateOut: String
            if let date = reminder.element.dueDateComponents?.date {
                dateOut = " - \(f.string(from: date))"
            } else {
                dateOut = ""
            }
            print("\(reminder.offset) \(reminder.element.lineDescription)\(dateOut)")
        })
        
        guard let line = readLine(),
              let doIndex = Int(line),
              doIndex < reminders.count
        else {
            print("Enter an index 0-\(reminders.count - 1) to mark a task done.")
            return
        }
        
        let logger = Logger()
        
        let reminder = reminders[doIndex]
        reminder.isCompleted.toggle()
        logger.debug("\(reminder.lineDescription), has changes : \(reminder.hasChanges)")
        
        
        try store.save(reminder, commit: false)
        // Room for other work
        try store.commit()
        
        logger.debug("\(reminder.lineDescription), has changes : \(reminder.hasChanges)")
    }
}

