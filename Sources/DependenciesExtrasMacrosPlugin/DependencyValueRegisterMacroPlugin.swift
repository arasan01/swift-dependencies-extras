import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

public struct DependencyValueRegisterMacro {}

extension DependencyValueRegisterMacro: DeclarationMacro {
    public static var formatMode: FormatMode = .disabled
    
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let arguments = node.argumentList
        guard
            arguments.count == 2,
            let argumentFirstMemberAccessExn = arguments.first?.expression.as(MemberAccessExprSyntax.self),
            let rawType = argumentFirstMemberAccessExn.base?.as(DeclReferenceExprSyntax.self)?.baseName.text,
            let propertyNameSyn = arguments.dropFirst().first?.expression.as(
                StringLiteralExprSyntax.self
            ),
            let propertyName = propertyNameSyn.segments.first?.as(StringSegmentSyntax.self)?.content.text
        else {
            return []
        }
        
        let macroUnderType = "_$\(rawType.replacingOccurrences(of: "Protocol", with: ""))"
        
        return [
            """
            public var \(raw: propertyName): \(raw: macroUnderType) {
                get { self[\(raw: macroUnderType).self] }
                set { self[\(raw: macroUnderType).self] = newValue }
            }
            """
        ]
    }
}
