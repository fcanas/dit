import XCTest

@testable import libDit

final class RecurrenceTest: XCTestCase {
    
    func testRecurrenceParsing() throws {
        let weekly = "w"
        XCTAssertEqual(try XCTUnwrap(Recurrence(weekly)), Recurrence(unit: .weekly, amount: 1))
        
        let weekly2 = "1w"
        XCTAssertEqual(try XCTUnwrap(Recurrence(weekly2)), Recurrence(unit: .weekly, amount: 1))
        
        let threeWeeks = "3w"
        XCTAssertEqual(try XCTUnwrap(Recurrence(threeWeeks)), Recurrence(unit: .weekly, amount: 3))
        
        let twelveDays = "12d"
        XCTAssertEqual(try XCTUnwrap(Recurrence(twelveDays)), Recurrence(unit: .daily, amount: 12))
        
        let monthy = "M"
        XCTAssertEqual(try XCTUnwrap(Recurrence(monthy)), Recurrence(unit: .monthly, amount: 1))
    }
    
}
