import FFCParserCombinator
import Foundation

struct Interval {
    
    static let years = Int.parser <* ("y" <|> "Y") <* CharacterSet.whitespaces.parser().many
    static let months = Int.parser <* ("m" <|> "M") <* CharacterSet.whitespaces.parser().many
    static let weeks = Int.parser <* ("w" <|> "W") <* CharacterSet.whitespaces.parser().many
    static let days = Int.parser <* ("d" <|> "D") <* CharacterSet.whitespaces.parser().many
    static let hours = Int.parser <* ("h" <|> "H") <* CharacterSet.whitespaces.parser().many
    static let minutes = Int.parser <* ("n" <|> "N") <* CharacterSet.whitespaces.parser().many
    
    // let years: Int
    // let months: Int
    // let weeks: Int
    // let days: Int
    // let hours: Int
    // let minutes: Int
    
    let dateComponents: DateComponents
    
    init(_ string: String) throws {
        
        var dc: DateComponents = DateComponents()
        
        let componentParser =
            ({ (value: Int?) -> Void in
                dc.year = value
            } <^> Interval.years.optional) <&>
            ({ (value: Int?) -> Void in
                dc.month = value
            } <^> Interval.months.optional) <&>
            ({ (value: Int?) -> Void in
                if let value = value {
                    dc.day = (dc.day ?? 0) + value * 7
                }
            } <^> Interval.weeks.optional) <&>
            ({ (value: Int?) -> Void in
                if let value = value {
                    dc.day = (dc.day ?? 0) + value
                }
            } <^> Interval.days.optional) <&>
            ({ (value: Int?) -> Void in
                dc.hour = value
            } <^> Interval.hours.optional) <&>
            ({ (value: Int?) -> Void in
                dc.minute = value
            } <^> Interval.minutes.optional)
        guard let r = componentParser.run(string) else {
            throw "Failed to understand interval.\nTry 1d for 1 day, 12h for 12 hours, or 1h45m for an hour and 45 minutes."
        }
        
        guard r.1.count == 0 else {
            throw "Unexpected output after the interval: \(r.1)"
        }
        self.dateComponents = dc
    }
}

extension UInt {
    var weeks: TimeInterval {
        self.days * 7
    }
    var days: TimeInterval {
        self.hours * 24
    }
    var hours: TimeInterval {
        self.minutes * 60
    }
    var minutes: TimeInterval {
        TimeInterval(self) * 60
    }
}

