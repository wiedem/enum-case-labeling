import SwiftDiagnostics
import SwiftSyntax

enum EnumCaseLabelingMacroDiagnostic {
    case requiresEnum
    case debug(String)
}

extension EnumCaseLabelingMacroDiagnostic: DiagnosticMessage {
    func diagnose(at node: some SyntaxProtocol) -> Diagnostic {
        Diagnostic(node: Syntax(node), message: self)
    }

    var message: String {
        switch self {
        case .requiresEnum:
            "'CaseLabeled' macro can only be applied to an enum"
        case let .debug(message):
            "'CaseLabeled' macro debug: \(message)"
        }
    }

    var severity: DiagnosticSeverity {
        switch self {
        case .requiresEnum:
            .error
        case .debug:
            .note
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "Swift", id: "CaseLabeled.\(self)")
    }
}
