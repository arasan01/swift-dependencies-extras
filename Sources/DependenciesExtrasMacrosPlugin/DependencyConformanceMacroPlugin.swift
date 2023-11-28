import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

public struct DependencyConformanceMacro {}



extension DependencyConformanceMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard declaration.is(StructDeclSyntax.self) else {
            context.diagnose(
                .init(
                    node: node,
                    message: MacroExpansionErrorMessage(
                        """
                        Struct declaration required, not supported other.
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
        
        let dependencyExtension = try ExtensionDeclSyntax(
            """
            extension \(raw: declRawName): TestDependencyKey {
                public static var testValue: \(raw: declRawName) {
                    \(raw: declRawName)()
                }
            }
            """
        )
        
        return [
            dependencyExtension
        ]
    }
}
