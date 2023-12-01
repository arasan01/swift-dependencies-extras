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
          attributeName: IdentifierTypeSyntax(
            name: .identifier("Sendable")
          )
        )
      )
    )
    let parameters = functionSyntax.signature.parameterClause.parameters
    let effects = functionSyntax.signature.effectSpecifiers
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
              FunctionParameterListSyntax,
              TupleTypeElementListSyntax
            >
            .convert(parameters),
            effectSpecifiers: TypeEffectSpecifiersSyntax(
              asyncSpecifier: effects?.asyncSpecifier,
              throwsSpecifier: effects?.throwsSpecifier
            ),
            returnClause: returnClause
              ?? ReturnClauseSyntax(
                type: IdentifierTypeSyntax(
                  name: .identifier("Void")
                )
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
                        trailingComma: p
                          != parameters.last
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
                      calledExpression:
                        DeclReferenceExprSyntax(
                          baseName: .identifier(
                            "unimplemented"
                          )
                        ),
                      leftParen: .leftParenToken(),
                      arguments: LabeledExprListSyntax([
                        LabeledExprSyntax(
                          expression:
                            StringLiteralExprSyntax(
                              openingQuote:
                                .stringQuoteToken(),
                              segments:
                                StringLiteralSegmentListSyntax(
                                  [
                                    .stringSegment(
                                      StringSegmentSyntax(
                                        content:
                                          .stringSegment(
                                            name
                                              .text
                                          )
                                      )
                                    )
                                  ]),
                              closingQuote:
                                .stringQuoteToken()
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
      let secondName = originalFirstName.flatMap {
        $0.text != "_" ? $0 : nil
      }
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

extension Converting
where Input == (TokenSyntax, VariableDeclSyntax), Output == ExprSyntax {
  static let convert = Converting { (callMember, varDecl) in
    guard let patternBinding = varDecl.bindings.first else {
      return .init(DeclReferenceExprSyntax(baseName: .identifier("miss")))
    }
    let name = patternBinding.pattern.cast(IdentifierPatternSyntax.self)
      .identifier
    let labels: [DeclNameArgumentSyntax]? = patternBinding.typeAnnotation?
      .type
      .as(AttributedTypeSyntax.self)?
      .baseType
      .as(FunctionTypeSyntax.self)?
      .parameters
      .compactMap { tupleType in
        if let secondName = tupleType.secondName {
          return DeclNameArgumentSyntax(name: secondName)
        }
        else {
          return DeclNameArgumentSyntax(name: .wildcardToken())
        }
      }
    let effectSpecifier: TypeEffectSpecifiersSyntax? = varDecl.bindings
      .compactMap(\.typeAnnotation?.type)
      .compactMap { $0.as(AttributedTypeSyntax.self) }
      .compactMap { $0.baseType.as(FunctionTypeSyntax.self) }
      .compactMap(\.effectSpecifiers)
      .compactMap { $0.as(TypeEffectSpecifiersSyntax.self) }
      .first
    var returnExpr: any ExprSyntaxProtocol = FunctionCallExprSyntax(
      calledExpression: MemberAccessExprSyntax(
        base: DeclReferenceExprSyntax(
          baseName: callMember
        ),
        period: .periodToken(),
        declName: DeclReferenceExprSyntax(
          baseName: name
        )
      ),
      leftParen: .leftParenToken(),
      arguments: LabeledExprListSyntax(
        labels?.enumerated()
          .map { (idx, label) in
            return LabeledExprSyntax(
              label: label.name,
              colon: .colonToken(),
              expression: DeclReferenceExprSyntax(
                baseName: .dollarIdentifier("$\(idx)")
              )
            )
          } ?? []
      ),
      rightParen: .rightParenToken()
    )
    if effectSpecifier?.asyncSpecifier?.text == "async" {
      returnExpr = AwaitExprSyntax(expression: returnExpr)
    }
    if [
      "throws",
      "rethrows",
    ]
    .contains(
      effectSpecifier?.throwsSpecifier?.text
    ) {
      returnExpr = TryExprSyntax(expression: returnExpr)
    }

    return .init(returnExpr)
  }
}
