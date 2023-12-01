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

    let baseNameAndFunctionCallExprs: [(TokenSyntax, ExprSyntax)] =
      try structDecl.memberBlock.members.compactMap {
        (decl: MemberBlockItemSyntax) -> (TokenSyntax, ExprSyntax)? in
        guard
          let varDecl = decl.decl.as(VariableDeclSyntax.self),
          let baseNameToken = varDecl.bindings.first?.pattern
            .as(IdentifierPatternSyntax.self)?
            .identifier
        else { return nil }
        let functionCallExpr: ExprSyntax = try Converting.convert<
          (TokenSyntax, VariableDeclSyntax), ExprSyntax
        >(
          (TokenSyntax.identifier("native"), varDecl)
        )
        return (baseNameToken, functionCallExpr)
      }
    let labeledExprs: [LabeledExprSyntax] =
      baseNameAndFunctionCallExprs.compactMap { (baseName, funcCallExpr) in

        return LabeledExprSyntax(
          label: baseName,
          colon: .colonToken(),
          expression: ClosureExprSyntax(
            statements: CodeBlockItemListSyntax([
              CodeBlockItemSyntax(
                item: .expr(
                  funcCallExpr
                )
              )
            ])
          ),
          trailingComma: funcCallExpr
            != baseNameAndFunctionCallExprs.last?.1
            ? .commaToken() : nil
        )
      }
    let labeledListExpr = LabeledExprListSyntax(labeledExprs)
      .formatted()

    let liveImplementExtension = try ExtensionDeclSyntax(
      """
      extension \(raw: declRawName): DependencyKey {
          public static var liveValue: \(raw: declRawName) {
              let underLive = \(raw: rawType)()
              \(raw: declRawName).from(underLive)
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
