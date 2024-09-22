/// A macro that implements labels for enum cases and conformance to the CaseLabeled protocol.
///
/// This macro adds labels to enum cases and conforms the type to the ``CaseLabeled`` protocol.
///
/// Case labels allow more convenient handling and comparison of enumeration cases with associated values.
/// The following code shows how to add case labels to a custom enum type:
///
/// ```swift
/// @CaseLabeled
/// enum MyEnum: Hashable, Sendable {
///     case `default`, simpleCase
///     case intValue(Int)
///     case stringValue(string: String?)
/// }
/// ```
@attached(member, names: arbitrary)
@attached(extension, conformances: CaseLabeled)
public macro CaseLabeled() = #externalMacro(module: "EnumCaseLabelingMacros", type: "EnumCaseLabelingMacro")
