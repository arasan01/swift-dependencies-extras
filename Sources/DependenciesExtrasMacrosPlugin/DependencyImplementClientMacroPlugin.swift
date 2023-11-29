import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

public struct DependencyImplementClientMacro {}

extension DependencyImplementClientMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        guard declaration.is(StructDeclSyntax.self) || declaration.is(ClassDeclSyntax.self) else {
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
            case .argumentList(let arguments) = node.arguments,
            arguments.count == 1,
            let argumentFirstMemberAccessExn = arguments.first?.expression.as(MemberAccessExprSyntax.self),
            let rawType = argumentFirstMemberAccessExn.base?.as(DeclReferenceExprSyntax.self)?.baseName.text
        else {
            return []
        }
        
        guard declaration.inheritanceClause?.inheritedTypes.contains(where: {
            $0.type.as(
                IdentifierTypeSyntax.self
            )?.name.text == rawType
        }) ?? false else {
            return []
        }
        
        
        let generatedStructClientName = generatedStructName(rawType)
        let liveImplementExtension = try ExtensionDeclSyntax(
            """
            extension \(raw: generatedStructClientName): DependencyKey {
                public static var liveValue: \(raw: generatedStructClientName) {
                    \(raw: generatedStructClientName)(fixme: fixme)
                }
            }
            """
        )
        return [liveImplementExtension]
    }
}
