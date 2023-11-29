import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

public struct DependencyLiveDepConformanceMacro {}

extension DependencyLiveDepConformanceMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard
            let structDecl = declaration.as(StructDeclSyntax.self)
        else {
            context.diagnose(
                .init(
                    node: node,
                    message: MacroExpansionErrorMessage(
                        """
                        Struct or Class declaration required, not supported other.
                        """
                    )
                )
            )
            return []
        }

        guard
            let declRawName = declaration.asProtocol(NamedDeclSyntax.self)?.name
                .text, !declRawName.isEmpty
        else {
            context.diagnose(
                .init(
                    node: node,
                    message: MacroExpansionErrorMessage(
                        """
                        declaration name invalid
                        """
                    )
                )
            )
            return []
        }

        guard
            let rawType = extractSingleTypeArgumentTokenSyntax(
                of: node,
                in: context
            )?
            .text
        else {
            return []
        }

        let memberAccessDeclReferenceExprs: [DeclReferenceExprSyntax] =
            try structDecl.memberBlock.members.compactMap {
                (decl: MemberBlockItemSyntax) -> DeclReferenceExprSyntax? in
                guard
                    let varDecl = decl.decl.as(VariableDeclSyntax.self)
                else { return nil }
                return try Converting.convert(varDecl)
            }
        let labeledExprs: [LabeledExprSyntax] =
            memberAccessDeclReferenceExprs.compactMap { refDecl in
                let labelName = refDecl.baseName
                return LabeledExprSyntax(
                    label: labelName,
                    colon: .colonToken(),
                    expression: MemberAccessExprSyntax(
                        base: DeclReferenceExprSyntax(
                            baseName: .identifier("native")
                        ),
                        period: .periodToken(),
                        declName: refDecl
                    ),
                    trailingComma: refDecl
                        != memberAccessDeclReferenceExprs.last
                        ? .commaToken() : nil
                )
            }
        let labeledListExpr = LabeledExprListSyntax(labeledExprs)
            .formatted()

        let liveImplementExtension = try ExtensionDeclSyntax(
            """
            extension \(raw: declRawName): DependencyKey {
                public static var liveValue: \(raw: declRawName) {
                    \(raw: declRawName).from(\(raw: rawType)())
                }

                public static func from(_ native: \(raw: rawType)) -> \(raw: declRawName) {
                    \(raw: declRawName)(\(labeledListExpr))
                }
            }
            """
        )
        .formatted()
        .cast(ExtensionDeclSyntax.self)
        return [liveImplementExtension]
    }
}
