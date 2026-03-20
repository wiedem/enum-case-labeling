/// A type that provides a case label.
///
/// Case labels offer a way of grouping different values of a type and making them comparable.
/// The associated ``CaseLabel`` type must conform to
/// [Hashable](https://developer.apple.com/documentation/swift/hashable) and
/// [Sendable](https://developer.apple.com/documentation/swift/sendable),
/// making it suitable for use in sets, as dictionary keys, and across concurrency boundaries.
///
/// The protocol is primarily intended for use with enumerations having cases with associated values.
///
/// The ``~~`` operator or the ``hasSameLabel(as:)`` method can be used to check whether two values
/// share the same case label:
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
/// value1 ~~ value2              // true
/// value1.hasSameLabel(as: value2) // true
/// ```
///
/// The `~=` operator allows pattern matching enum values against ``CaseLabel`` values:
///
/// ```swift
/// value1 ~= .intValue     // true
/// value1 ~= .stringValue  // false
/// ```
public protocol CaseLabeled {
    associatedtype CaseLabel: Hashable, Sendable
    var caseLabel: CaseLabel { get }
}

infix operator ~~: ComparisonPrecedence

public extension CaseLabeled {
    /// Returns `true` if both values share the same case label.
    func hasSameLabel(as other: Self) -> Bool {
        caseLabel == other.caseLabel
    }

    /// Returns `true` if both values share the same case label.
    static func ~~ (lhs: Self, rhs: Self) -> Bool {
        lhs.caseLabel == rhs.caseLabel
    }

    /// Returns `true` if the value's case label matches the given label.
    static func ~= (lhs: Self, rhs: CaseLabel) -> Bool {
        lhs.caseLabel == rhs
    }

    /// Returns `true` if the given label matches the value's case label.
    static func ~= (lhs: CaseLabel, rhs: Self) -> Bool {
        lhs == rhs.caseLabel
    }
}
