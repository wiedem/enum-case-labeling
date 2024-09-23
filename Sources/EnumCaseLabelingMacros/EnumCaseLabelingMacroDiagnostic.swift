import SwiftDiagnostics
import SwiftSyntax

enum EnumCaseLabelingMacroDiagnostic {
    case requiresEnum
}

extension EnumCaseLabelingMacroDiagnostic: DiagnosticMessage {
    func diagnose(at node: some SyntaxProtocol) -> Diagnostic {
        Diagnostic(node: Syntax(node), message: self)
    }

    var message: String {
        switch self {
        case .requiresEnum:
            "'CaseLabeled' macro can only be applied to an enum"
        }
    }

    var severity: DiagnosticSeverity { .error }

    var diagnosticID: MessageID {
        MessageID(domain: "Swift", id: "CaseLabeled.\(self)")
    }
}
