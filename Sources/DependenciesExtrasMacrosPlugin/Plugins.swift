import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DependencyProtocolClientMacro.self,
        DependencyConformanceMacro.self,
        DependencyValueRegisterMacro.self,
        DependencyImplementClientMacro.self
    ]
}
