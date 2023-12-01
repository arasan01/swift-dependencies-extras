import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main struct MacrosPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    DependencyProtocolClientMacro.self,
    DependencyTestDepConformanceMacro.self,
    DependencyLiveDepConformanceMacro.self,
    DependencyValueRegisterMacro.self,
  ]
}
