import ArgumentParser
import EventKit


struct Create: ParsableCommand {
    
    @Option(name: .shortAndLong, help: "The list to create the reminder in")
    var list: String?
    
    @Argument(help: "Title for the new reminder")
    var title: String
    
    @Option(name: .shortAndLong, help: "", transform: Interval.init)
    var dueIn: Interval?
    
    func run() throws {
        
        let configuration: Configuration = Configuration()
        
        let store = EKEventStore()
        try store.sync.authorize()
        
        guard let targetList = list ?? configuration.targetList else {
            throw "No list to create a reminder in. Specify one with the --list option or the configure command."
        }
        
        guard let list = store.calendar(named: targetList) else {
            throw "No list named\"\(targetList)\" found"
        }
        
        let reminder = EKReminder(eventStore: store)
        reminder.calendar = list
        reminder.title = title
        
        if let dueInterval = dueIn {
            let calendar = Calendar.current
            guard let dueDate = calendar.date(byAdding: dueInterval.dateComponents, to: Date()) else {
                throw "Unable to determine date from due-in parameter"
            }
            let dueComponents = calendar.dateComponents(in: calendar.timeZone, from: dueDate)
            reminder.dueDateComponents = dueComponents
        }
        
        try store.save(reminder, commit: true)
    }
}

extension Calendar.Component {
    var all: Set<Calendar.Component> {
        return [.era, .year, .month, .day, .hour, .minute, .timeZone]
    }
}

