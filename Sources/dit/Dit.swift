import ArgumentParser
import EventKit

struct Dit: ParsableCommand {
    
    static var configuration = CommandConfiguration(abstract: "Manipulate reminders",
                                                    version: "0.0.1",
                                                    subcommands: [Query.self, Create.self, Lists.self, Configure.self],
                                                    defaultSubcommand: Query.self)
}
