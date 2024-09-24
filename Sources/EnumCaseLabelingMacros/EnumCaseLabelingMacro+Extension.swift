import SwiftSyntax
import SwiftSyntaxMacros

extension EnumCaseLabelingMacro: ExtensionMacro {
    public static func expansion(
        of _: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard protocols.isEmpty == false else {
            return []
        }

        return makeExtensionDeclList(
            declaration: declaration,
            extensionsOf: type,
            protocols: protocols,
            context: context
        )
    }
}

extension EnumCaseLabelingMacro {
    static func makeDefaultExtensionDeclList(
        extensionsOf type: some TypeSyntaxProtocol
    ) -> [ExtensionDeclSyntax] {
        let extensionDecl = ExtensionDeclSyntax(
            extendedType: type,
            inheritanceClause: .init(
                inheritedTypes: .init {
                    InheritedTypeSyntax(
                        type: IdentifierTypeSyntax(name: .identifier("CaseLabeled"))
                    )
                }
            )
        ) {}
        return [extensionDecl]
    }

    static func makeExtensionDeclList(
        declaration: some DeclGroupSyntax,
        extensionsOf type: some TypeSyntaxProtocol,
        protocols: [TypeSyntax],
        context: some MacroExpansionContext
    ) -> [ExtensionDeclSyntax] {
        let extensionDecl = ExtensionDeclSyntax(
            extendedType: type,
            inheritanceClause: .init(
                inheritedTypes: .init {
                    for inheritanceType in protocols {
                        InheritedTypeSyntax(type: inheritanceType)
                    }
                }
            )
        ) {}
        return [extensionDecl]
    }
}
