import Dependencies

@attached(peer, names: prefixed(_$))
public macro DependencyProtocolClient() = #externalMacro(
    module: "DependenciesExtrasMacrosPlugin",
    type: "DependencyProtocolClientMacro"
)

@attached(extension, conformances: TestDependencyKey, names: named(testValue))
public macro DependencyConformance() = #externalMacro(
    module: "DependenciesExtrasMacrosPlugin",
    type: "DependencyConformanceMacro"
)

@attached(extension, conformances: DependencyKey, names: named(liveValue))
public macro DependencyImplementClient<T>(of: T.Type) = #externalMacro(
    module: "DependenciesExtrasMacrosPlugin",
    type: "DependencyImplementClientMacro"
)

@freestanding(declaration, names: arbitrary)
public macro DependencyValueRegister<T>(of: T.Type, into property: String) = #externalMacro(
    module: "DependenciesExtrasMacrosPlugin",
    type: "DependencyValueRegisterMacro"
)
