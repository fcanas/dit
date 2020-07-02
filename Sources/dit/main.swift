import ArgumentParser
import EventKit

struct List: ParsableCommand {
    
    func run() throws {
        
        let store = EKEventStore()
        store.requestAccess(to: .reminder) { (access, error) in
            guard access else {
                print("dit needs access to your reminders to be useful.")
                return
            }
            let predicate = store.predicateForReminders(in: nil)
            
            store.enumerateEvents(matching: predicate) { (event, stop) in
                print(event)
            }
        }
    }
    
}

List.main()
