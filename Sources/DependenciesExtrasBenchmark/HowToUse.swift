import DependenciesExtrasMacros
import Foundation

extension DependencyValues {
  #DependencyValueRegister(of: GreatTool.self, into: "great")
}

@DependencyProtocolClient(implemented: Implements.self)
public protocol GreatTool {
  func foo(a: Int) async -> Int
  func hoge(_ b: Double) async throws -> Double
  func yes(_ what: inout String) async -> Bool
}

public actor Implements: GreatTool {
  var x = 1
  var y = 1.0
  public func yes(_ what: inout String) -> Bool { true }
  public func foo(a: Int) -> Int {
    x += 1
    return x
  }
  public func hoge(_ b: Double) throws -> Double {
    y += 1
    return y
  }
}

struct Runner {
    
    @Dependency(\.great) var great
    
    func run() async throws {
        let new = withDependencies {
            $0.great.foo = { @Sendable _ in 42 }
            $0.great.yes = { @Sendable _ in false }
        } operation: {
            great
        }
        var m = ""
        let a = await new.yes(&m)
        assert(a == false, "missing override")
        let b = await new.foo(a: 0)
        assert(b == 42, "missing override")
        let c = try await new.hoge(0)
        assert(c == 2.0, "missing macro")
        
        print("Great !! Nice work.")
    }
}

@main
struct MainApp {
    static func main() async throws {
        let runner = Runner()
        try await runner.run()
    }
}

