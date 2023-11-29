import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

public struct DependencyProtocolClientMacro {}

extension DependencyProtocolClientMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
            context.diagnose(
                .init(
                    node: node,
                    message: MacroExpansionErrorMessage(
                        """
                        Protocol declaration required, not supported other.
                        """
                    )
                )
            )
            return []
        }

        guard
            let implementedType = extractSingleTypeArgumentTokenSyntax(
                of: node,
                in: context
            )?
            .text
        else {
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
                        applying macro declaration name is invalid
                        """
                    )
                )
            )
            return []
        }

        let generatedStructClientName = generatedStructName(declRawName)

        let newMemberItemsBlock = try protocolDecl.memberBlock.members
            .compactMap {
                (decl: MemberBlockItemSyntax) -> MemberBlockItemSyntax? in
                guard
                    let funcDecl = decl.decl.as(FunctionDeclSyntax.self)
                else { return nil }
                let newDecl: VariableDeclSyntax = try Converting.convert(
                    funcDecl
                )
                return MemberBlockItemSyntax(decl: newDecl)
            }

        let variables = MemberBlockItemListSyntax(newMemberItemsBlock)
            .formatted()

        return [
            """
            @DependencyTestDepConformance
            @DependencyLiveDepConformance(of: \(raw: implementedType).self)
            @DependencyClient
            public struct \(raw: generatedStructClientName) {
                \(variables)
            }
            """
        ]
    }
}
