/// A type that provides a case label.
///
/// Conformance to this protocol makes a case label available to other APIs that fulfill the [Equatable](https://developer.apple.com/documentation/swift/equatable) protocol.
///
/// Case labels offer a way of grouping different values of a type and making them comparable.
/// The protocol is primarily intended for use with enumerations having cases with associated types.
///
/// The `~=` operator can be used to compare types implementing `CaseLabeled`; if the ``caseLabel-swift.property`` value is the same, the operator returns true:
///
/// ```swift
/// @CaseLabeled
/// enum MyEnum {
///     case `default`, simpleCase
///     case intValue(Int)
///     case stringValue(string: String?)
/// }
///
/// let value1: MyEnum = .intValue(1)
/// let value2: MyEnum = .intValue(2)
///
/// if value1 ~= value2 {
///     print("Enum values '\(value1)' and '\(value2)' have a common case label")
/// }
/// ```
public protocol CaseLabeled {
    associatedtype CaseLabel: Equatable
    var caseLabel: CaseLabel { get }
}

public extension CaseLabeled {
    static func ~= (lhs: Self, rhs: Self) -> Bool {
        lhs.caseLabel == rhs.caseLabel
    }

    static func ~= (lhs: Self, rhs: CaseLabel) -> Bool {
        lhs.caseLabel == rhs
    }

    static func ~= (lhs: CaseLabel, rhs: Self) -> Bool {
        lhs == rhs.caseLabel
    }
}
