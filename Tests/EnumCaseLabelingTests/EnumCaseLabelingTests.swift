import EnumCaseLabeling
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(EnumCaseLabelingMacros)
    import EnumCaseLabelingMacros

    let testMacros: [String: Macro.Type] = [
        "CaseLabeled": EnumCaseLabelingMacro.self,
    ]
#endif

final class EnumCaseLabelingTests: XCTestCase {
    func testMacroExpansionAddsRequiredCode() throws {
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
                    case `default`, simpleCase, intValue, stringValue
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
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
