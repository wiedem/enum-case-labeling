import SwiftDiagnostics
import SwiftSyntax

enum EnumCaseLabelingMacroDiagnostic {
    case requiresEnum
    case noAssociatedValues
}

extension EnumCaseLabelingMacroDiagnostic: DiagnosticMessage {
    func diagnose(at node: some SyntaxProtocol) -> Diagnostic {
        Diagnostic(node: Syntax(node), message: self)
    }

    var message: String {
        switch self {
        case .requiresEnum:
            "'CaseLabeled' macro can only be applied to an enum"
        case .noAssociatedValues:
            "'CaseLabeled' macro is redundant on enums where no case has associated values"
        }
    }

    var severity: DiagnosticSeverity {
        switch self {
        case .requiresEnum:
            .error
        case .noAssociatedValues:
            .warning
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "EnumCaseLabeling", id: "CaseLabeled.\(self)")
    }
}
