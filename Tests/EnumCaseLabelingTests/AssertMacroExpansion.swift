import SwiftSyntax
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing

func assertMacroExpansion(
    _ originalSource: String,
    expandedSource expectedExpandedSource: String,
    diagnostics: [DiagnosticSpec] = [],
    macroSpecs: [String: MacroSpec],
    applyFixIts: [String]? = nil,
    fixedSource expectedFixedSource: String? = nil,
    indentationWidth: SwiftSyntax.Trivia = .spaces(4),
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column
) {
    SwiftSyntaxMacrosGenericTestSupport.assertMacroExpansion(
        originalSource,
        expandedSource: expectedExpandedSource,
        diagnostics: diagnostics,
        macroSpecs: macroSpecs,
        applyFixIts: applyFixIts,
        fixedSource: expectedFixedSource,
        indentationWidth: indentationWidth,
        failureHandler: { spec in
            Issue.record(
                Comment(rawValue: spec.message),
                sourceLocation: SourceLocation(
                    fileID: spec.location.fileID,
                    filePath: spec.location.filePath,
                    line: spec.location.line,
                    column: spec.location.column
                )
            )
        },
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
    )
}
