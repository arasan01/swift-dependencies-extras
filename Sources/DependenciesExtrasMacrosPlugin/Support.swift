import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

extension SyntaxStringInterpolation {
    mutating func appendInterpolation<Node: SyntaxProtocol>(_ node: Node?) {
        if let node { self.appendInterpolation(node) }
    }
}
