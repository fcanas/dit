import EventKit
import FFCParserCombinator

public struct Recurrence: Hashable {
    
    internal init(unit: EKRecurrenceFrequency, amount: Int) {
        self.unit = unit
        self.amount = amount
    }

    public init(_ string: String) throws {
        guard let parsed = Recurrence.parser.run(string) else {
            throw "Could not understand recurrence '\(string)'. [0-9]*(d|D|w|W|m|M|y|Y)."
        }
        guard parsed.1.count == 0 else {
            throw "Interpreted recurrence as \(parsed.1), but could not understand remaining input: '\(parsed.1)'"
        }
        self = parsed.0
    }
    
    private static let yearly = { _ in EKRecurrenceFrequency.yearly } <^> ("y" <|> "Y")
    private static let monthly = { _ in EKRecurrenceFrequency.monthly } <^> ("m" <|> "M")
    private static let weekly = { _ in EKRecurrenceFrequency.weekly } <^> ("w" <|> "W")
    private static let daily = { _ in EKRecurrenceFrequency.daily } <^> ("d" <|> "D")
    
    private static let parser = { (amount, unit) in Recurrence(unit: unit, amount: amount ?? 1) } <^> Int.parser.optional <&> (yearly <|> monthly <|> weekly <|> daily)
    
    var unit: EKRecurrenceFrequency
    var amount: Int
    
    public func ek() -> EKRecurrenceRule {
        EKRecurrenceRule(recurrenceWith: unit, interval: amount, end: nil)
    }
    
}
