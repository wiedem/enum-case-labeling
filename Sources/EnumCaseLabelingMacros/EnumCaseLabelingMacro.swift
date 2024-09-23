import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct EnumCaseLabelingMacro: MemberMacro {
    public static func expansion(
        of _: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            return []
        }

        let isPublicEnum = enumDecl.modifiers.contains { modifier in
            modifier.name.text == "public"
        }

        var labelModifiers: DeclModifierListSyntax = []
        if isPublicEnum {
            labelModifiers.append(
                DeclModifierSyntax(name: .keyword(.public))
            )
        }

        let caseElements = enumDecl.memberBlock.members
            .compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
            .map {
                $0.elements.map {
                    EnumCaseElementSyntax(name: $0.name)
                }
            }
            .flatMap { $0 }

        guard caseElements.isEmpty == false else {
            return []
        }

        // Create the CaseLabel declaration.
        let enumCaseElementList = EnumCaseElementListSyntax.init {
            for element in caseElements {
                element
            }
        }
        let enumCase = EnumCaseDeclSyntax(elements: enumCaseElementList)

        let inheritanceTypeList = InheritedTypeListSyntax {
            InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("Hashable")))
            InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("CaseIterable")))
            InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("Sendable")))
        }

        let labelEnumDecl = EnumDeclSyntax(
            modifiers: labelModifiers,
            name: .identifier("CaseLabel"),
            inheritanceClause: .init(inheritedTypes: inheritanceTypeList)
        ) {
            enumCase
        }

        let labelCaseList = caseElements.map { enumCaseElement in
            SwitchCaseSyntax(
                label: .case(.init(
                    caseItems: .init {
                        .init(pattern: ExpressionPatternSyntax(
                            expression: MemberAccessExprSyntax(
                                declName: .init(baseName: enumCaseElement.name)
                            )
                        ))
                    }
                )),
                statements: .init {
                    MemberAccessExprSyntax(
                        declName: .init(
                            baseName: enumCaseElement.name
                        )
                    )
                }
            )
        }

        // Create the caseLabel var declaration.
        let labelVarDecl = VariableDeclSyntax(
            modifiers: labelModifiers,
            bindingSpecifier: .keyword(.var),
            bindings: .init {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: .identifier("caseLabel")),
                    typeAnnotation: .init(
                        type: IdentifierTypeSyntax(
                            name: .identifier("CaseLabel")
                        )
                    ),
                    accessorBlock: AccessorBlockSyntax(
                        accessors: .init(
                            CodeBlockItemListSyntax {
                                CodeBlockItemSyntax(item: .init(ExpressionStmtSyntax(
                                    expression: SwitchExprSyntax(
                                        subject: DeclReferenceExprSyntax(baseName: .keyword(.self)),
                                        cases: SwitchCaseListSyntax {
                                            for switchCase in labelCaseList {
                                                switchCase
                                            }
                                        }
                                    )
                                )))
                            }
                        )
                    )
                )
            }
        )

        return [
            DeclSyntax(labelEnumDecl),
            DeclSyntax(labelVarDecl),
        ]
    }
}

extension EnumCaseLabelingMacro: ExtensionMacro {
    public static func expansion(
        of _: AttributeSyntax,
        attachedTo _: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in _: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard protocols.isEmpty == false else {
            return []
        }

        let labeledExtension: DeclSyntax =
            """
            extension \(type.trimmed): \(raw: protocols.first!.trimmed) {}
            """

        guard let extensionDecl = labeledExtension.as(ExtensionDeclSyntax.self) else {
            return []
        }

        return [extensionDecl]
    }
}

@main
struct EnumCaseLabelingPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EnumCaseLabelingMacro.self,
    ]
}
