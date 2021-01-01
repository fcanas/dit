import EventKit

extension EKEventStore {
    var sync: SynchronousEventStore {
        SynchronousEventStore(store: self)
    }
}

struct SynchronousEventStore {
    
    internal init(store: EKEventStore) {
        self.store = store
    }
    
    private let store: EKEventStore
    private let wait = DispatchGroup()
    
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
    
    func fetchReminders(matching predicate: NSPredicate) -> [EKReminder] {
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
