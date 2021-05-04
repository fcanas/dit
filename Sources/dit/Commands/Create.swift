import ArgumentParser
import EventKit
import libDit

struct Create: ParsableCommand {
    
    static var configuration: CommandConfiguration = CommandConfiguration(abstract: "Create a new reminder.")
    
    @Option(name: .shortAndLong, help: "The list to create the reminder in")
    var list: String?
    
    @Argument(help: "Title for the new reminder")
    var title: String
    
    @Option(name: .shortAndLong, help: "An interval specifying how far from now the reminder is due, specified in mi\("n".underline)utes, \("h".underline)ours, \("d".underline)ays, \("w".underline)eeks, \("m".underline)onths, and \("y".underline)ears. These units can be combined in ascending order, e.g. \("1y2m17h22s".bold)", transform: Interval.init)
    var dueIn: Interval?
    
    @Option(name: .shortAndLong, help: "How often the reminder should repeat, in \("d".underline)ays, \("w".underline)eeks, \("m".underline)onths, and \("y".underline)ears. These units cannot be comined. e.g. \("3w".bold), \("y".bold), \("d".bold), \("24d".bold)" )
    var repeats: Recurrence?
    
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
        
        if let recurrence = repeats {
            reminder.recurrenceRules = [recurrence.ek()]
        }
        
        try store.save(reminder, commit: true)
    }
}

extension Calendar.Component {
    var all: Set<Calendar.Component> {
        return [.era, .year, .month, .day, .hour, .minute, .timeZone]
    }
}

