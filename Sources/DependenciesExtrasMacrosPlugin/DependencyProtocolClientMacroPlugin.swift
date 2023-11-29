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
    else { return [] }

    let generatedStructClientName = generatedStructName(declRawName)

    let newMemberItemsBlock = try protocolDecl.memberBlock.members.map {
      if let funcDecl = $0.decl.as(FunctionDeclSyntax.self) {
        let newDecl: VariableDeclSyntax = try Converting.convert(funcDecl)
        return MemberBlockItemSyntax(decl: newDecl)
      }
      else {
        return $0
      }
    }

    let variables = MemberBlockItemListSyntax(newMemberItemsBlock).formatted()

    return [
      """
      @DependencyConformance
      @DependencyClient
      public struct \(raw: generatedStructClientName) {
          \(variables)
      }
      """
    ]
  }
}

//struct DeclElement {
//    var
//}
