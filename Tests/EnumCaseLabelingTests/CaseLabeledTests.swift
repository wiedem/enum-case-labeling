import EnumCaseLabeling
import Testing

@Suite("CaseLabeled Protocol")
struct CaseLabeledTests {
    @Test("Returns true for identical simple cases using ~~ operator")
    func sameLabelOperator() {
        let value1 = TestEnum.simpleCase
        let value2 = TestEnum.simpleCase
        #expect(value1 ~~ value2)
        #expect(value2 ~~ value1)
    }

    @Test("Returns true for same case with different associated values using ~~ operator")
    func sameLabelWithDifferentAssociatedValuesOperator() {
        let value1 = TestEnum.intValue(1)
        let value2 = TestEnum.intValue(2)
        #expect(value1 ~~ value2)
        #expect(value2 ~~ value1)
    }

    @Test("Returns false for different cases using ~~ operator")
    func differentLabelOperator() {
        let value1 = TestEnum.simpleCase
        let value2 = TestEnum.intValue(1)
        #expect(!(value1 ~~ value2))
        #expect(!(value2 ~~ value1))
    }

    @Test("Returns true for identical simple cases using hasSameLabel")
    func sameLabelMethod() {
        let value1 = TestEnum.simpleCase
        let value2 = TestEnum.simpleCase
        #expect(value1.hasSameLabel(as: value2))
        #expect(value2.hasSameLabel(as: value1))
    }

    @Test("Returns true for same case with different associated values using hasSameLabel")
    func sameLabelWithDifferentAssociatedValuesMethod() {
        let value1 = TestEnum.intValue(1)
        let value2 = TestEnum.intValue(2)
        #expect(value1.hasSameLabel(as: value2))
        #expect(value2.hasSameLabel(as: value1))
    }

    @Test("Returns false for different cases using hasSameLabel")
    func differentLabelMethod() {
        let value1 = TestEnum.simpleCase
        let value2 = TestEnum.intValue(1)
        #expect(!value1.hasSameLabel(as: value2))
        #expect(!value2.hasSameLabel(as: value1))
    }

    @Test("Returns true when value matches its CaseLabel")
    func comparisonWithMatchingLabel() {
        #expect(TestEnum.intValue(1) ~= .intValue)
        #expect(.intValue ~= TestEnum.intValue(1))
    }

    @Test("Returns false when value does not match CaseLabel")
    func comparisonWithNonMatchingLabel() {
        #expect(!(TestEnum.simpleCase ~= .intValue))
        #expect(!(.intValue ~= TestEnum.simpleCase))
    }

    @Test("CaseLabel provides all cases via CaseIterable")
    func caseLabelCaseIterable() {
        let allCases = TestEnum.CaseLabel.allCases
        #expect(allCases.count == 3)
        #expect(allCases.contains(.simpleCase))
        #expect(allCases.contains(.intValue))
        #expect(allCases.contains(.stringValue))
    }

    @Test("CaseLabel is usable as Set element")
    func caseLabelInSet() {
        let labels: Set<TestEnum.CaseLabel> = [.simpleCase, .intValue, .simpleCase]
        #expect(labels.count == 2)
        #expect(labels.contains(.simpleCase))
        #expect(labels.contains(.intValue))
    }

    @Test("CaseLabel is usable as Dictionary key")
    func caseLabelAsDictionaryKey() {
        let dict: [TestEnum.CaseLabel: String] = [
            .simpleCase: "simple",
            .intValue: "int",
        ]
        #expect(dict[.simpleCase] == "simple")
        #expect(dict[.intValue] == "int")
        #expect(dict[.stringValue] == nil)
    }
}

@Suite("CaseLabel Access in Nested Enums")
struct NestedEnumCaseLabelTests {
    @Test("Public enum's caseLabel is accessible from enclosing type")
    func publicNestedEnum() {
        #expect(ContainerWithPublicEnum.verifyCaseLabelAccess())
    }

    @Test("Public enum's caseLabel is accessible from outside the enclosing type")
    func publicNestedEnumExternalAccess() {
        let value = ContainerWithPublicEnum.Nested.a(1)
        #expect(value.caseLabel == .a)
        #expect(value ~= .a)
    }

    @Test("Internal enum's caseLabel is accessible from enclosing type")
    func internalNestedEnum() {
        #expect(ContainerWithInternalEnum.verifyCaseLabelAccess())
    }

    @Test("Private enum with explicit CaseLabeled conformance works from enclosing type")
    func privateNestedEnumWithExplicitConformance() {
        #expect(ContainerWithPrivateEnum.verifyCaseLabelAccess())
    }

    @Test("Private enum with explicit CaseLabeled conformance supports ~~ operator")
    func privateNestedEnumComparison() {
        #expect(ContainerWithPrivateEnum.verifyCaseLabelComparison())
    }
}

@CaseLabeled
private enum TestEnum: Hashable, Sendable {
    case simpleCase
    case intValue(Int)
    case stringValue(string: String?)
}

// MARK: - Nested enum scenarios for access level verification

public enum ContainerWithPublicEnum {
    @CaseLabeled
    public enum Nested {
        case a(Int)
        case b(String)
    }

    public static func verifyCaseLabelAccess() -> Bool {
        let value = Nested.a(1)
        return value.caseLabel == .a
    }
}

private enum ContainerWithPrivateEnum {
    @CaseLabeled
    private enum Nested: CaseLabeled {
        case a(Int)
        case b(String)
    }

    static func verifyCaseLabelAccess() -> Bool {
        let value = Nested.a(1)
        return value.caseLabel == .a
    }

    static func verifyCaseLabelComparison() -> Bool {
        let value1 = Nested.a(1)
        let value2 = Nested.a(2)
        return value1 ~~ value2
    }
}

private enum ContainerWithInternalEnum {
    @CaseLabeled
    enum Nested {
        case a(Int)
        case b(String)
    }

    static func verifyCaseLabelAccess() -> Bool {
        let value = Nested.a(1)
        return value.caseLabel == .a
    }
}
