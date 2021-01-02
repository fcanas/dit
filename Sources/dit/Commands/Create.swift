import ArgumentParser
import EventKit


struct Create: ParsableCommand {
    
    @Option(name: .shortAndLong, help: "The list to create the reminder in")
    var list: String?
    
    @Argument(help: "Title for the new reminder")
    var title: String
    
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
        try store.save(reminder, commit: true)
    }
    
}



class Configuration {
    enum PreferenceKey {
        static let targetList = "com.fcanas.dit.reminders.targetList"
    }
    
    var targetList: String? {
        get {
            UserDefaults.standard.string(forKey: Configuration.PreferenceKey.targetList)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Configuration.PreferenceKey.targetList)
        }
    }
    
}

struct Configure: ParsableCommand {
    
    @Option(name: .shortAndLong, help: "Set the default target List when creating a reminder")
    var target: String?
    
    func run() throws {
        
        let configuration: Configuration = Configuration()
        
        let store = EKEventStore()
        try store.sync.authorize()
        
        var wroteAChange = false
        
        let calendars = store.calendars(for: .reminder)
        
        if let targetTitle = target {
            let eligible = calendars.filter { (calendar) -> Bool in
                calendar.title == target
            }
            guard eligible.count > 0 else {
                throw "Could not find a List named \(targetTitle)"
            }
            configuration.targetList = targetTitle
            wroteAChange = true
        }
        
        if wroteAChange == false {
            print(
                """
                Target List :\t\(configuration.targetList ?? "<not set>")
                """)
        }
        
    }
    
}
