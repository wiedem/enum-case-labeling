import SwiftCompilerPlugin
import SwiftSyntaxMacros

public enum EnumCaseLabelingMacro {}

@main
struct EnumCaseLabelingPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EnumCaseLabelingMacro.self,
    ]
}
