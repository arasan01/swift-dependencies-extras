import SwiftSyntax
import Foundation

func generatedStructName(_ raw: String) -> String {
  "_$\(raw.replacingOccurrences(of: "Protocol", with: ""))"
}

func variableName(_ raw: String) -> String {
  raw.prefix(1).lowercased() + raw.dropFirst(1)
}

func checkReturnClauseIsVoid(_ returnClause: ReturnClauseSyntax?) -> Bool {
  returnClause == nil || returnClause?.type.as(IdentifierTypeSyntax.self)?.name.text == "Void"
}
