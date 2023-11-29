import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

func generatedStructName(_ raw: String) -> String {
    "_$\(raw)"
}

func variableName(_ raw: String) -> String {
    raw.prefix(1).lowercased() + raw.dropFirst(1)
}

func checkReturnClauseIsVoid(_ returnClause: ReturnClauseSyntax?) -> Bool {
    returnClause == nil
        || returnClause?.type.as(IdentifierTypeSyntax.self)?.name.text == "Void"
}

func extractSingleTypeArgumentTokenSyntax(
    of node: AttributeSyntax,
    in context: some MacroExpansionContext
) -> TokenSyntax? {
    guard case .argumentList(let arguments) = node.arguments,
        arguments.count == 1,
        let argumentFirstMemberAccessExn = arguments.first?.expression
            .as(MemberAccessExprSyntax.self),
        let implementedType = argumentFirstMemberAccessExn.base?
            .as(DeclReferenceExprSyntax.self)?
            .baseName
    else {
        context.diagnose(
            .init(
                node: node,
                message: MacroExpansionErrorMessage(
                    """
                    Argument missing
                    """
                )
            )
        )
        return nil
    }
    return implementedType
}
