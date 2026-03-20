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
            extensionsOf: type,
            protocols: protocols
        )
    }
}

extension EnumCaseLabelingMacro {
    static func makeExtensionDeclList(
        extensionsOf type: some TypeSyntaxProtocol,
        protocols: [TypeSyntax]
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
