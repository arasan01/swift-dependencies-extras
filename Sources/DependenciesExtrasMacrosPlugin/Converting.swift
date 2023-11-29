import Foundation
import SwiftSyntax

struct Converting<Input, Output> {
  var run: (Input) throws -> Output

  init(run: @escaping (Input) throws -> Output) { self.run = run }

  func callAsFunction(_ v: Input) throws -> Output { try run(v) }
}

extension Converting
where Input == FunctionDeclSyntax, Output == VariableDeclSyntax {
  static let convert = Converting { functionSyntax in
    var attributes = functionSyntax.attributes
    attributes.append(
      AttributeListSyntax.Element(
        AttributeSyntax(
          atSign: .atSignToken(),
          attributeName: IdentifierTypeSyntax(name: .identifier("Sendable"))
        )
      )
    )
    let parameters = functionSyntax.signature.parameterClause.parameters
    let returnClause = functionSyntax.signature.returnClause
    let name = functionSyntax.name

    return try VariableDeclSyntax(
      modifiers: DeclModifierListSyntax([
        DeclModifierSyntax(name: .keyword(.public))
      ]),
      .var,
      name: PatternSyntax(IdentifierPatternSyntax(identifier: name)),
      type: TypeAnnotationSyntax(
        type: AttributedTypeSyntax(
          attributes: attributes,
          baseType: FunctionTypeSyntax(
            leadingTrivia: .space,
            parameters: Converting<
              FunctionParameterListSyntax, TupleTypeElementListSyntax
            >
            .convert(parameters),
            returnClause: returnClause
              ?? ReturnClauseSyntax(
                type: IdentifierTypeSyntax(name: .identifier("Void"))
              )
          )
        )
      ),
      initializer: checkReturnClauseIsVoid(returnClause)
        ? nil
        : InitializerClauseSyntax(
          value: ClosureExprSyntax(
            signature: ClosureSignatureSyntax(
              parameterClause: .parameterClause(
                ClosureParameterClauseSyntax(
                  parameters: ClosureParameterListSyntax(
                    parameters.map { p in
                      ClosureParameterSyntax(
                        firstName: .identifier("_"),
                        trailingComma: p != parameters.last
                          ? .commaToken() : nil
                      )
                    }
                  )
                )
              )
            ),
            statements: CodeBlockItemListSyntax([
              CodeBlockItemSyntax(
                item: .expr(
                  ExprSyntax(
                    FunctionCallExprSyntax(
                      calledExpression: DeclReferenceExprSyntax(
                        baseName: .identifier("unimplemented")
                      ),
                      leftParen: .leftParenToken(),
                      arguments: LabeledExprListSyntax([
                        LabeledExprSyntax(
                          expression: StringLiteralExprSyntax(
                            openingQuote: .stringQuoteToken(),
                            segments: StringLiteralSegmentListSyntax([
                              .stringSegment(
                                StringSegmentSyntax(
                                  content: .stringSegment(name.text)
                                )
                              )
                            ]),
                            closingQuote: .stringQuoteToken()
                          )
                        )
                      ]),
                      rightParen: .rightParenToken()
                    )
                  )
                )
              )
            ])
          )
        )
    )
  }
}

extension Converting
where Input == FunctionParameterListSyntax, Output == TupleTypeElementListSyntax
{
  static let convert = Converting { parameters in
    let elements: [TupleTypeElementSyntax] = parameters.map { fp in
      let originalFirstName = fp.firstToken(viewMode: .sourceAccurate)
      let secondName = originalFirstName.flatMap { $0.text != "_" ? $0 : nil }
      return TupleTypeElementSyntax(
        firstName: .wildcardToken(),
        secondName: secondName,
        colon: .colonToken(),
        type: fp.type,
        trailingComma: fp != parameters.last ? .commaToken() : nil
      )
    }
    return TupleTypeElementListSyntax(elements)
  }
}
