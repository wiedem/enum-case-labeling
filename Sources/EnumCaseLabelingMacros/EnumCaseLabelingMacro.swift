import SwiftCompilerPlugin
import SwiftSyntaxMacros

public enum EnumCaseLabelingMacro {
    static let emitDiagnostics = false
}

@main
struct EnumCaseLabelingPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EnumCaseLabelingMacro.self,
    ]
}
