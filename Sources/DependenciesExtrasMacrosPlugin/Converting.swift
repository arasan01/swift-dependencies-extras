import Foundation
import SwiftSyntax

struct Converting<
  Input,
  Output
> {
  var run: (
    Input
  ) throws -> Output
  
  init(
    run: @escaping (
      Input
    ) throws -> Output
  ) {
    self.run = run
  }
  
  func callAsFunction(
    _ v: Input
  ) throws -> Output {
    try run(
      v
    )
  }
}

extension Converting where Input == FunctionDeclSyntax, Output == VariableDeclSyntax {
  static let convert = Converting { functionSyntax in
    var attributes = functionSyntax.attributes
    attributes.append(
      AttributeListSyntax.Element(
        AttributeSyntax(
          atSign: .atSignToken(),
          attributeName: IdentifierTypeSyntax(
            name: .identifier(
              "Sendable"
            )
          )
        )
      )
    )
    let parameters = functionSyntax.signature.parameterClause.parameters
    let returnClause = functionSyntax.signature.returnClause
    let name = functionSyntax.name
    
    return try VariableDeclSyntax(
      modifiers: DeclModifierListSyntax(
        [DeclModifierSyntax(
          name: .keyword(
            .public
          )
        )]
      ),
      .var,
      name: PatternSyntax(
        IdentifierPatternSyntax(
          identifier: name
        )
      ),
      type: TypeAnnotationSyntax(
        type: AttributedTypeSyntax(
          attributes: attributes,
          baseType: FunctionTypeSyntax(
            leadingTrivia: .space,
            parameters: Converting<FunctionParameterListSyntax,
            TupleTypeElementListSyntax>.convert(
              parameters
            ),
            returnClause: returnClause ?? ReturnClauseSyntax(
              type: IdentifierTypeSyntax(
                name: .identifier(
                  "Void"
                )
              )
            )
          )
        )
      ),
      initializer: checkReturnClauseIsVoid(returnClause) ? nil : InitializerClauseSyntax(
        value: ClosureExprSyntax(
          signature: ClosureSignatureSyntax(
            parameterClause: .init(
              ClosureShorthandParameterListSyntax(parameters.map {
                _ in
                ClosureShorthandParameterSyntax(
                  name: .identifier(
                    "_"
                  )
                )
              })
            )
          ),
          statements: CodeBlockItemListSyntax(
            [CodeBlockItemSyntax(
              item: .expr(
                ExprSyntax(
                  MemberAccessExprSyntax(
                    declName: DeclReferenceExprSyntax(
                      baseName: .identifier(
                        "mock"
                      )
                    )
                  )
                )
              )
            )]
          )
        )
      )
    )
    }
}

extension Converting where Input == FunctionParameterListSyntax, Output == TupleTypeElementListSyntax {
  static let convert = Converting { parameters in
    return []
  }
}
