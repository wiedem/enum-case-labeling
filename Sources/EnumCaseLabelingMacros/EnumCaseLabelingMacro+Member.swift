import SwiftSyntax
import SwiftSyntaxMacros

extension EnumCaseLabelingMacro: MemberMacro {
    public static func expansion(
        of _: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let (caseLabelMembers, labelModifiers) = getEnumCaseLabelMembers(
            declaration: declaration,
            in: context
        ) else {
            return []
        }

        guard hasCases(caseLabelMembers) else {
            return []
        }

        let labelEnumDecl = makeCaseLabelEnumDecl(
            members: caseLabelMembers,
            declarationModifiers: labelModifiers
        )

        let labelVarDecl = makeCaseLabelVarDecl(
            members: caseLabelMembers,
            declarationModifiers: labelModifiers
        )

        return [
            DeclSyntax(labelEnumDecl),
            DeclSyntax(labelVarDecl),
        ]
    }
}

// MARK: - CaseLabelMember

extension EnumCaseLabelingMacro {
    indirect enum CaseLabelMember {
        case caseDecl(attributes: AttributeListSyntax, elements: [EnumCaseElementSyntax])
        case ifConfig(clauses: [IfConfigClause])

        struct IfConfigClause {
            let poundKeyword: TokenSyntax
            let condition: ExprSyntax?
            let members: [CaseLabelMember]
        }
    }
}

// MARK: - Extraction

extension EnumCaseLabelingMacro {
    static func getEnumCaseLabelMembers(
        declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) -> ([CaseLabelMember], DeclModifierListSyntax)? {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            context.diagnose(
                EnumCaseLabelingMacroDiagnostic.requiresEnum.diagnose(at: declaration)
            )
            return nil
        }

        let caseLabelMembers = extractCaseLabelMembers(from: enumDecl.memberBlock.members, in: context)

        if hasCases(caseLabelMembers),
           !hasAssociatedValues(enumDecl.memberBlock.members)
        {
            context.diagnose(
                EnumCaseLabelingMacroDiagnostic.noAssociatedValues.diagnose(at: enumDecl)
            )
        }

        let labelModifiers = makeLabelModifierList(declaration: enumDecl)

        return (caseLabelMembers, labelModifiers)
    }

    static func extractCaseLabelMembers(
        from members: MemberBlockItemListSyntax,
        in context: some MacroExpansionContext
    ) -> [CaseLabelMember] {
        var result: [CaseLabelMember] = []
        for member in members {
            if let enumCaseDecl = member.decl.as(EnumCaseDeclSyntax.self) {
                let elements = enumCaseDecl.elements.map {
                    EnumCaseElementSyntax(name: $0.name)
                }
                result.append(.caseDecl(
                    attributes: enumCaseDecl.attributes,
                    elements: Array(elements)
                ))
            } else if let ifConfigDecl = member.decl.as(IfConfigDeclSyntax.self) {
                let clauses = ifConfigDecl.clauses.map { clause in
                    CaseLabelMember.IfConfigClause(
                        poundKeyword: clause.poundKeyword,
                        condition: clause.condition,
                        members: extractCaseLabelMembersFromClause(clause, in: context)
                    )
                }
                if clauses.contains(where: { !$0.members.isEmpty }) {
                    result.append(.ifConfig(clauses: clauses))
                }
            }
        }
        return result
    }

    static func extractCaseLabelMembersFromClause(
        _ clause: IfConfigClauseSyntax,
        in context: some MacroExpansionContext
    ) -> [CaseLabelMember] {
        if case let .decls(memberList) = clause.elements {
            return extractCaseLabelMembers(from: memberList, in: context)
        }
        return []
    }

    static func hasAssociatedValues(_ members: MemberBlockItemListSyntax) -> Bool {
        members.contains { member in
            if let enumCaseDecl = member.decl.as(EnumCaseDeclSyntax.self) {
                return enumCaseDecl.elements.contains { $0.parameterClause != nil }
            }
            if let ifConfigDecl = member.decl.as(IfConfigDeclSyntax.self) {
                return ifConfigDecl.clauses.contains { clause in
                    if case let .decls(memberList) = clause.elements {
                        return hasAssociatedValues(memberList)
                    }
                    return false
                }
            }
            return false
        }
    }

    static func hasCases(_ members: [CaseLabelMember]) -> Bool {
        members.contains { member in
            switch member {
            case let .caseDecl(_, elements): !elements.isEmpty
            case let .ifConfig(clauses): clauses.contains { hasCases($0.members) }
            }
        }
    }
}

// MARK: - Access Modifiers

extension EnumCaseLabelingMacro {
    static func makeLabelModifierList(declaration: EnumDeclSyntax) -> DeclModifierListSyntax {
        let accessKeywords: [Keyword] = [.public, .package]
        for modifier in declaration.modifiers {
            if case let .keyword(keyword) = modifier.name.tokenKind,
               accessKeywords.contains(keyword)
            {
                return DeclModifierListSyntax {
                    DeclModifierSyntax(name: .keyword(keyword))
                }
            }
        }
        return DeclModifierListSyntax {}
    }
}

// MARK: - CaseLabel Enum Generation

extension EnumCaseLabelingMacro {
    static func makeCaseLabelEnumDecl(
        members: [CaseLabelMember],
        declarationModifiers: DeclModifierListSyntax
    ) -> EnumDeclSyntax {
        let inheritanceTypeList = InheritedTypeListSyntax {
            InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("Hashable")))
            InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("CaseIterable")))
            InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("Sendable")))
        }

        return EnumDeclSyntax(
            modifiers: declarationModifiers,
            name: .identifier("CaseLabel"),
            inheritanceClause: .init(inheritedTypes: inheritanceTypeList),
            memberBlock: MemberBlockSyntax(
                members: makeCaseLabelMemberBlockItems(from: members)
            )
        )
    }

    static func makeCaseLabelMemberBlockItems(
        from members: [CaseLabelMember]
    ) -> MemberBlockItemListSyntax {
        MemberBlockItemListSyntax(
            members.map { makeCaseLabelMemberBlockItem(for: $0) }
        )
    }

    static func makeCaseLabelMemberBlockItem(
        for member: CaseLabelMember
    ) -> MemberBlockItemSyntax {
        switch member {
        case let .caseDecl(attributes, elements):
            MemberBlockItemSyntax(
                decl: EnumCaseDeclSyntax(
                    attributes: attributes,
                    elements: EnumCaseElementListSyntax {
                        for element in elements {
                            element
                        }
                    }
                )
            )
        case let .ifConfig(clauses):
            MemberBlockItemSyntax(
                decl: IfConfigDeclSyntax(
                    clauses: IfConfigClauseListSyntax {
                        for clause in clauses {
                            IfConfigClauseSyntax(
                                poundKeyword: clause.poundKeyword,
                                condition: clause.condition,
                                elements: .decls(
                                    makeCaseLabelMemberBlockItems(from: clause.members)
                                )
                            )
                        }
                    }
                )
            )
        }
    }
}

// MARK: - caseLabel Property Generation

extension EnumCaseLabelingMacro {
    static func makeCaseLabelVarDecl(
        members: [CaseLabelMember],
        declarationModifiers: DeclModifierListSyntax
    ) -> VariableDeclSyntax {
        VariableDeclSyntax(
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
                                        cases: makeSwitchCaseList(from: members)
                                    )
                                )))
                            }
                        )
                    )
                )
            }
        )
    }

    static func makeSwitchCaseList(
        from members: [CaseLabelMember]
    ) -> SwitchCaseListSyntax {
        SwitchCaseListSyntax {
            for member in members {
                switch member {
                case let .caseDecl(_, elements):
                    for element in elements {
                        SwitchCaseSyntax(
                            label: .case(.init(
                                caseItems: .init {
                                    .init(pattern: ExpressionPatternSyntax(
                                        expression: MemberAccessExprSyntax(
                                            declName: .init(baseName: element.name)
                                        )
                                    ))
                                }
                            )),
                            statements: .init {
                                MemberAccessExprSyntax(
                                    declName: .init(
                                        baseName: element.name
                                    )
                                )
                            }
                        )
                    }
                case let .ifConfig(clauses):
                    IfConfigDeclSyntax(
                        clauses: IfConfigClauseListSyntax {
                            for clause in clauses {
                                IfConfigClauseSyntax(
                                    poundKeyword: clause.poundKeyword,
                                    condition: clause.condition,
                                    elements: .switchCases(
                                        makeSwitchCaseList(from: clause.members)
                                    )
                                )
                            }
                        }
                    )
                }
            }
        }
    }
}
