import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum EnumCaseLabelingMacro {
    static let emitDiagnostics = false

    static func getEnumCaseElements(
        declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext,
        emitDiagnostics: Bool
    ) -> ([EnumCaseElementSyntax], DeclModifierListSyntax)? {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            if emitDiagnostics {
                context.diagnose(
                    EnumCaseLabelingMacroDiagnostic.requiresEnum.diagnose(at: declaration)
                )
            }
            return nil
        }

        let enumCaseElements = enumDecl.memberBlock.members
            .compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
            .map {
                $0.elements.map {
                    EnumCaseElementSyntax(name: $0.name)
                }
            }
            .flatMap { $0 }

        let labelModifiers = makeLabelModifierList(declaration: enumDecl)

        return (enumCaseElements, labelModifiers)
    }

    static func makeLabelModifierList(declaration _: EnumDeclSyntax) -> DeclModifierListSyntax {
        DeclModifierListSyntax {
            DeclModifierSyntax(name: .keyword(.public))
        }
    }

    static func makeCaseLabelEnumDecl(
        caseElements: [EnumCaseElementSyntax],
        declarationModifiers: DeclModifierListSyntax
    ) -> EnumDeclSyntax {
        let caseElementList = EnumCaseElementListSyntax {
            for element in caseElements {
                element
            }
        }
        let enumCaseDecl = EnumCaseDeclSyntax(elements: caseElementList)

        let inheritanceTypeList = InheritedTypeListSyntax {
            InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("Hashable")))
            InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("CaseIterable")))
            InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("Sendable")))
        }

        return EnumDeclSyntax(
            modifiers: declarationModifiers,
            name: .identifier("CaseLabel"),
            inheritanceClause: .init(inheritedTypes: inheritanceTypeList)
        ) {
            enumCaseDecl
        }
    }

    static func makeCaseLabelVarDecl(
        caseElements: [EnumCaseElementSyntax],
        declarationModifiers: DeclModifierListSyntax
    ) -> VariableDeclSyntax {
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

        return VariableDeclSyntax(
            modifiers: declarationModifiers,
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
    }
}

extension EnumCaseLabelingMacro: MemberMacro {
    public static func expansion(
        of _: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let (labelCaseElements, labelModifiers) = getEnumCaseElements(
            declaration: declaration,
            in: context,
            emitDiagnostics: emitDiagnostics
        ) else {
            return []
        }

        guard labelCaseElements.isEmpty == false else {
            return []
        }

        // Create the CaseLabel declaration.
        let labelEnumDecl = makeCaseLabelEnumDecl(
            caseElements: labelCaseElements,
            declarationModifiers: labelModifiers
        )

        // Create the caseLabel var declaration.
        let labelVarDecl = makeCaseLabelVarDecl(
            caseElements: labelCaseElements,
            declarationModifiers: labelModifiers
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
