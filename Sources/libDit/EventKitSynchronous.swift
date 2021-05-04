import EventKit

extension EKEventStore {
    public var sync: SynchronousEventStore {
        SynchronousEventStore(store: self)
    }
    
    public func calendar(named: String, entityType: EKEntityType = .reminder) -> EKCalendar? {
        calendars(for: entityType).first { (cal) -> Bool in
            cal.title == named
        }
    }
}

extension String: Error {}

public struct SynchronousEventStore {
    
    internal init(store: EKEventStore) {
        self.store = store
    }
    
    private let store: EKEventStore
    private let wait = DispatchGroup()
    
    public func authorize() throws {
        let hasAccess: Bool = store.sync.requestAccess(to: .reminder)
        
        guard hasAccess == true else {
            throw "dit needs access to your reminders to be useful."
        }
    }
    
    func requestAccess(to type: EKEntityType) -> Bool {
        var hasAccess: Bool?
        wait.enter()
        store.requestAccess(to: type) { (access, error) in
            defer { wait.leave() }
            hasAccess = access
        }
        wait.wait()
        return hasAccess ?? false
    }
    
    public func fetchReminders(matching predicate: NSPredicate) -> [EKReminder] {
        var remindersOut: [EKReminder]?
        wait.enter()
        store.fetchReminders(matching: predicate) { (reminders) in
            defer { wait.leave() }
            remindersOut = reminders
        }
        wait.wait()
        return remindersOut ?? []
    }
    
}
