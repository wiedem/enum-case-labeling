import EnumCaseLabeling
import XCTest

@CaseLabeled
private enum MyEnum: Hashable, Sendable {
    case simpleCase
    case intValue(Int)
    case stringValue(string: String?)
}

final class CaseLabeledTests: XCTestCase {
    func testSameLabelComparisonReturnsTrue() throws {
        let value1 = MyEnum.simpleCase
        let value2 = MyEnum.simpleCase
        XCTAssertTrue(value1 ~= value2)
        XCTAssertTrue(value2 ~= value1)
    }

    func testSameLabelComparisonWithAssociatedValuesReturnsTrue() {
        let value1 = MyEnum.intValue(1)
        let value2 = MyEnum.intValue(2)
        XCTAssertTrue(value1 ~= value2)
        XCTAssertTrue(value2 ~= value1)
    }

    func testDifferentLabelComparisonReturnsFalse() {
        let value1 = MyEnum.simpleCase
        let value2 = MyEnum.intValue(1)
        XCTAssertFalse(value1 ~= value2)
        XCTAssertFalse(value2 ~= value1)
    }

    func testComparisonWithMatchingLabelReturnsTrue() throws {
        XCTAssertTrue(MyEnum.intValue(1) ~= .intValue)
        XCTAssertTrue(.intValue ~= MyEnum.intValue(1))
    }

    func testComparisonWithNonMatchingLabelReturnsFalse() throws {
        XCTAssertFalse(MyEnum.simpleCase ~= .intValue)
        XCTAssertFalse(.intValue ~= MyEnum.simpleCase)
    }
}
