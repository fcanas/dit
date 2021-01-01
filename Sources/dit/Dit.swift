import ArgumentParser
import EventKit

struct Dit: ParsableCommand {
    
    static var configuration = CommandConfiguration(abstract: "Manipulate reminders",
                                                    version: "0.0.1",
                                                    subcommands: [Reminders.self, Lists.self],
                                                    defaultSubcommand: Reminders.self)
    struct Reminders: ParsableCommand {
        
        @Flag(help: "Show completed reminders.")
        var complete = false
        
        @Flag(help: "All completed and pending reminders.")
        var all = false
        
        @Option(name: .shortAndLong, help: "The interval in days. Matches due dates in the future and completion date in the past.")
        var days: Int = 1
        
        @Option(name: .shortAndLong, help: "The interval in hours. Matches due dates in the future and completion date in the past.")
        var hours: Int = 0
        
        @Option(name: .shortAndLong, help: "The interval in minutes. Matches due dates in the future and completion date in the past.")
        var minutes: Int = 0
        
        func run() throws {
            
            let store = EKEventStore()
            
            let hasAccess: Bool = store.sync.requestAccess(to: .reminder)
            
            guard hasAccess == true else {
                print("dit needs access to your reminders to be useful.")
                return
            }
            
            let calendars = store.calendars(for: .reminder)
            guard calendars.count > 0 else {
                print("No calendar with reminders found.")
                return
            }
            
            let searchInterval = TimeInterval(days).days + TimeInterval(hours).hours + TimeInterval(minutes).minutes
            
            let predicate: NSPredicate
            if all {
                predicate = store.predicateForReminders(in: calendars)
            } else if complete {
                predicate = store.predicateForCompletedReminders(withCompletionDateStarting: Date().addingTimeInterval(-searchInterval), ending: Date(), calendars: calendars)
            } else {
                predicate = store.predicateForIncompleteReminders(withDueDateStarting: Date(), ending: Date().addingTimeInterval(searchInterval), calendars: calendars)
            }
            
            let reminders = store.sync.fetchReminders(matching: predicate)
            reminders.forEach({ (reminder) in
                print("[ ] \(reminder.title ?? "")")
            })
        }
    }
    
    struct Lists: ParsableCommand {
        
        func run() throws {
            
            let store = EKEventStore()
            
            let hasAccess: Bool = store.sync.requestAccess(to: .reminder)
            
            guard hasAccess == true else {
                print("dit needs access to your reminders to be useful.")
                return
            }
            
            let calendars = store.calendars(for: .reminder)
            guard calendars.count > 0 else {
                print("No calendar with reminders found.")
                return
            }
            
            let calendarIteration = zip(calendars,Naturals())
            calendarIteration.forEach { (calendar, number) in
                print("[\(number)] \(calendar.title)")
            }
        }
    }
}
