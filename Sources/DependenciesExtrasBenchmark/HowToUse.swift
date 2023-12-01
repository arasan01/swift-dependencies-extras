import DependenciesExtrasMacros
import Foundation

extension DependencyValues {
  #DependencyValueRegister(of: AGreatTool.self, into: "agreat")
  #DependencyValueRegister(of: CGreatTool.self, into: "cgreat")
}

@DependencyProtocolClient(implemented: CImplements.self)
public protocol CGreatTool {
  func foo(a: Int) -> Int
  func hoge(_ b: Double) throws -> Double
  func yes(_ what: inout String) -> Bool
}

public final class CImplements: @unchecked Sendable, CGreatTool {
  public func foo(a: Int) -> Int {
    self.x += 1
    return x
  }

  public func hoge(_ b: Double) throws -> Double {
    self.y += 1
    return y
  }

  var x = 1
  var y = 1.0

  public func yes(_ what: inout String) -> Bool { true }
}

@DependencyProtocolClient(implemented: AImplements.self)
public protocol AGreatTool {
  func foo(a: Int) async -> Int
  func hoge(_ b: Double) async throws -> Double
  func yes(_ what: inout String) async -> Bool
}

public actor AImplements: AGreatTool {
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

  @Dependency(\.agreat) var agreat
  @Dependency(\.cgreat) var cgreat

  func run() async throws {
    do {
      let new = withDependencies {
        $0.agreat.foo = { @Sendable _ in
          try! await Task.sleep(nanoseconds: 1_000_000)
          return 42
        }
        $0.agreat.yes = { @Sendable _ in false }
      } operation: {
        agreat
      }
      var m = ""
      let a = await new.yes(&m)
      assert(a == false, "missing override")
      let b = await new.foo(a: 0)
      assert(b == 42, "missing override")
      let c = try await new.hoge(0)
      assert(c == 2.0, "missing macro")
    }

    do {
      let new = withDependencies {
        $0.cgreat.foo = { @Sendable _ in 42 }
        $0.cgreat.yes = { @Sendable _ in false }
      } operation: {
        cgreat
      }
      var m = ""
      let a = new.yes(&m)
      assert(a == false, "missing override")
      let b = new.foo(a: 0)
      assert(b == 42, "missing override")
      let c = try new.hoge(0)
      assert(c == 2.0, "missing macro")
    }

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
