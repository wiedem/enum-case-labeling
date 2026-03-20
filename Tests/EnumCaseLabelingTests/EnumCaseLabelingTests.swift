import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

#if canImport(EnumCaseLabelingMacros)
import EnumCaseLabelingMacros

private var testMacros: [String: Macro.Type] {
    ["CaseLabeled": EnumCaseLabelingMacro.self]
}
#endif

@Suite("CaseLabeled Macro Expansion")
struct EnumCaseLabelingTests {
    @Test("Generates CaseLabel enum and caseLabel property for enum with mixed cases")
    func mixedCases() {
        #if canImport(EnumCaseLabelingMacros)
        assertMacroExpansion(
            """
            @CaseLabeled
            enum MyEnum: Equatable, Sendable {
                case `default`, simpleCase
                case intValue(Int)
                case stringValue(string: String?)
            }
            """,
            expandedSource: """
            enum MyEnum: Equatable, Sendable {
                case `default`, simpleCase
                case intValue(Int)
                case stringValue(string: String?)

                enum CaseLabel: Hashable, CaseIterable, Sendable {
                    case `default`, simpleCase
                    case intValue
                    case stringValue
                }

                var caseLabel: CaseLabel {
                    switch self {
                    case .`default`:
                        .`default`
                    case .simpleCase:
                        .simpleCase
                    case .intValue:
                        .intValue
                    case .stringValue:
                        .stringValue
                    }
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    @Test("Generates labels for enum with only simple cases and emits warning")
    func onlySimpleCases() {
        #if canImport(EnumCaseLabelingMacros)
        assertMacroExpansion(
            """
            @CaseLabeled
            enum Direction {
                case north, south
                case east, west
            }
            """,
            expandedSource: """
            enum Direction {
                case north, south
                case east, west

                enum CaseLabel: Hashable, CaseIterable, Sendable {
                    case north, south
                    case east, west
                }

                var caseLabel: CaseLabel {
                    switch self {
                    case .north:
                        .north
                    case .south:
                        .south
                    case .east:
                        .east
                    case .west:
                        .west
                    }
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "'CaseLabeled' macro is redundant on enums where no case has associated values",
                    line: 1,
                    column: 1,
                    severity: .warning
                ),
            ],
            macros: testMacros
        )
        #endif
    }

    @Test("Omits access modifier for private enum members")
    func privateEnum() {
        #if canImport(EnumCaseLabelingMacros)
        assertMacroExpansion(
            """
            @CaseLabeled
            private enum MyEnum {
                case intValue(Int)
            }
            """,
            expandedSource: """
            private enum MyEnum {
                case intValue(Int)

                enum CaseLabel: Hashable, CaseIterable, Sendable {
                    case intValue
                }

                var caseLabel: CaseLabel {
                    switch self {
                    case .intValue:
                        .intValue
                    }
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    @Test("Uses public access level for public enum members")
    func publicEnum() {
        #if canImport(EnumCaseLabelingMacros)
        assertMacroExpansion(
            """
            @CaseLabeled
            public enum MyEnum {
                case intValue(Int)
            }
            """,
            expandedSource: """
            public enum MyEnum {
                case intValue(Int)

                public enum CaseLabel: Hashable, CaseIterable, Sendable {
                    case intValue
                }

                public var caseLabel: CaseLabel {
                    switch self {
                    case .intValue:
                        .intValue
                    }
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    @Test("Uses package access level for package enum members")
    func packageEnum() {
        #if canImport(EnumCaseLabelingMacros)
        assertMacroExpansion(
            """
            @CaseLabeled
            package enum MyEnum {
                case intValue(Int)
            }
            """,
            expandedSource: """
            package enum MyEnum {
                case intValue(Int)

                package enum CaseLabel: Hashable, CaseIterable, Sendable {
                    case intValue
                }

                package var caseLabel: CaseLabel {
                    switch self {
                    case .intValue:
                        .intValue
                    }
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    @Test("Emits error diagnostic when applied to a struct")
    func appliedToStruct() {
        #if canImport(EnumCaseLabelingMacros)
        assertMacroExpansion(
            """
            @CaseLabeled
            struct MyStruct {
                let value: Int
            }
            """,
            expandedSource: """
            struct MyStruct {
                let value: Int
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "'CaseLabeled' macro can only be applied to an enum",
                    line: 1,
                    column: 1
                ),
            ],
            macros: testMacros
        )
        #endif
    }

    @Test("Produces empty expansion for enum without cases")
    func emptyEnum() {
        #if canImport(EnumCaseLabelingMacros)
        assertMacroExpansion(
            """
            @CaseLabeled
            enum EmptyEnum {
            }
            """,
            expandedSource: """
            enum EmptyEnum {
            }
            """,
            macros: testMacros
        )
        #endif
    }

    @Test("Preserves @available attributes on case labels")
    func availableAttribute() {
        #if canImport(EnumCaseLabelingMacros)
        assertMacroExpansion(
            """
            @CaseLabeled
            enum Feature {
                case basic
                @available(iOS 17, *)
                case advanced(String)
            }
            """,
            expandedSource: """
            enum Feature {
                case basic
                @available(iOS 17, *)
                case advanced(String)

                enum CaseLabel: Hashable, CaseIterable, Sendable {
                    case basic
                    @available(iOS 17, *)
                    case advanced
                }

                var caseLabel: CaseLabel {
                    switch self {
                    case .basic:
                        .basic
                    case .advanced:
                        .advanced
                    }
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    @Test("Generates CaseLabel with #if conditional compilation block")
    func ifConfigBlock() {
        #if canImport(EnumCaseLabelingMacros)
        assertMacroExpansion(
            """
            @CaseLabeled
            enum Feature {
                case basic
                #if DEBUG
                case debugOnly(String)
                #endif
            }
            """,
            expandedSource: """
            enum Feature {
                case basic
                #if DEBUG
                case debugOnly(String)
                #endif

                enum CaseLabel: Hashable, CaseIterable, Sendable {
                    case basic
                    #if DEBUG
                    case debugOnly
                    #endif
                }

                var caseLabel: CaseLabel {
                    switch self {
                    case .basic:
                        .basic
                    #if DEBUG
                    case .debugOnly:
                        .debugOnly
                    #endif
                    }
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    @Test("Generates CaseLabel with #if/#else conditional compilation block")
    func ifElseConfigBlock() {
        #if canImport(EnumCaseLabelingMacros)
        assertMacroExpansion(
            """
            @CaseLabeled
            enum Platform {
                case common
                #if os(iOS)
                case iosOnly(String)
                #else
                case otherPlatform(Int)
                #endif
            }
            """,
            expandedSource: """
            enum Platform {
                case common
                #if os(iOS)
                case iosOnly(String)
                #else
                case otherPlatform(Int)
                #endif

                enum CaseLabel: Hashable, CaseIterable, Sendable {
                    case common
                    #if os(iOS)
                    case iosOnly
                    #else
                    case otherPlatform
                    #endif
                }

                var caseLabel: CaseLabel {
                    switch self {
                    case .common:
                        .common
                    #if os(iOS)
                    case .iosOnly:
                        .iosOnly
                    #else
                    case .otherPlatform:
                        .otherPlatform
                    #endif
                    }
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    @Test("Emits warning when no case has associated values")
    func noAssociatedValuesWarning() {
        #if canImport(EnumCaseLabelingMacros)
        assertMacroExpansion(
            """
            @CaseLabeled
            enum SimpleEnum {
                case a
                case b
            }
            """,
            expandedSource: """
            enum SimpleEnum {
                case a
                case b

                enum CaseLabel: Hashable, CaseIterable, Sendable {
                    case a
                    case b
                }

                var caseLabel: CaseLabel {
                    switch self {
                    case .a:
                        .a
                    case .b:
                        .b
                    }
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "'CaseLabeled' macro is redundant on enums where no case has associated values",
                    line: 1,
                    column: 1,
                    severity: .warning
                ),
            ],
            macros: testMacros
        )
        #endif
    }
}
