import ArgumentParser
import EventKit

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
