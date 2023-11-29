import Dependencies

@attached(peer, names: prefixed(_$))
public macro DependencyProtocolClient<T>(implemented: T.Type) =
    #externalMacro(
        module: "DependenciesExtrasMacrosPlugin",
        type: "DependencyProtocolClientMacro"
    )

@attached(extension, conformances: TestDependencyKey, names: named(testValue))
public macro DependencyTestDepConformance() =
    #externalMacro(
        module: "DependenciesExtrasMacrosPlugin",
        type: "DependencyTestDepConformanceMacro"
    )

@attached(
    extension,
    conformances: DependencyKey,
    names: named(liveValue),
    named(from)
)
public macro DependencyLiveDepConformance<T>(of: T.Type) =
    #externalMacro(
        module: "DependenciesExtrasMacrosPlugin",
        type: "DependencyLiveDepConformanceMacro"
    )

@freestanding(declaration, names: arbitrary)
public macro DependencyValueRegister<T>(of: T.Type, into property: String) =
    #externalMacro(
        module: "DependenciesExtrasMacrosPlugin",
        type: "DependencyValueRegisterMacro"
    )
