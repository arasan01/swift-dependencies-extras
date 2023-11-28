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
            let declRawName = declaration.asProtocol(NamedDeclSyntax.self)?.name.text,
            !declRawName.isEmpty
        else {
            return []
        }
        
        
        let declName = declRawName.replacingOccurrences(of: "Protocol", with: "")
        let generatedStructClientName = "_$\(declName)"
        
        let prefixLowercasedDeclName = declName.prefix(1).lowercased() + declName.dropFirst(1)
        
        protocolDecl.memberBlock.members
        
        return [
            """
            @DependencyConformance
            @DependencyClient
            public struct \(raw: generatedStructClientName) {
                var todo: @Sendable (_ id: Int) -> Int = { _ in .previewValue(0) }
            }
            """
        ]
    }
}

//struct DeclElement {
//    var
//}
