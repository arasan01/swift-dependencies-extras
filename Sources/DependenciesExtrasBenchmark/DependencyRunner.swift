import DependenciesExtrasMacros
import Foundation

extension DependencyValues {
    #DependencyValueRegister(of: GreatTool.self, into: "great")
}

@DependencyProtocolClient(implemented: Implements.self)
public protocol GreatTool {
    func foo(a: Int) -> Int
    func hoge(_ b: Double) -> Double
    func yes() -> Bool
}

public class Implements: GreatTool {
    var x = 1
    var y = 2.0
    @Sendable public func yes() -> Bool { true }
    @Sendable public func foo(a: Int) -> Int { x }
    @Sendable public func hoge(_ b: Double) -> Double { y }
}

struct Runner {
    func run() async throws {
        @Dependency(\.great) var great
        let new = withDependencies {
            $0.great.foo = { @Sendable _ in 42 }
            $0.great.yes = { @Sendable in false }
        } operation: {
            great
        }
        assert(new.yes() == false, "missing override")
        assert(new.foo(a: 0) == 42, "missing override")
        assert(new.hoge(0) == 2.0, "missing macro")

        print("Great !! Nice work.")
    }
}
