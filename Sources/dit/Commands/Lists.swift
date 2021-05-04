import ArgumentParser
import EventKit
import libDit

struct Lists: ParsableCommand {
    
    func run() throws {
        
        let store = EKEventStore()
        try store.sync.authorize()
        
        let calendars = store.calendars(for: .reminder)
        guard calendars.count > 0 else {
            print("No calendar with reminders found.")
            return
        }
        
        let calendarIteration = zip(calendars,Naturals())
        calendarIteration.forEach { (calendar, number) in
            print("[\(number)] \(calendar.title.underline)")
        }
    }
}
