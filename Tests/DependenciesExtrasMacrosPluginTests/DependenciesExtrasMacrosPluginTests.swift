import DependenciesExtrasMacrosPlugin
import MacroTesting
import XCTest

final class DependenciesExtrasMacrosPluginTests: XCTestCase {
  override func invokeTest() {
    withMacroTesting(
      // isRecording: true,
      macros: [
        DependencyProtocolClientMacro.self,
        DependencyTestDepConformanceMacro.self,
        DependencyValueRegisterMacro.self,
        DependencyLiveDepConformanceMacro.self,
      ]
    ) { super.invokeTest() }
  }

  func testImplement() {
    assertMacro {
      """
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
          var y = 2.0
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
      """
    } expansion: {
      """
      extension DependencyValues {
          public var great: _$GreatTool {
              get { self[_$GreatTool.self] }
              set { self[_$GreatTool.self] = newValue }
          }
      }
      public protocol GreatTool {
          func foo(a: Int) async -> Int
          func hoge(_ b: Double) async throws -> Double
          func yes(_ what: inout String) async -> Bool
      }
      @DependencyClient
      public struct _$GreatTool: Sendable {
          public var foo: @Sendable (_ a: Int) async -> Int = { (_) in
              unimplemented("foo")
          }
          public var hoge: @Sendable (_: Double) async throws -> Double = { (_) in
              unimplemented("hoge")
          }
          public var yes: @Sendable (_: inout String) async -> Bool = { (_) in
              unimplemented("yes")
          }
      }

      public actor Implements: GreatTool {
          var x = 1
          var y = 2.0
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

      extension _$GreatTool: TestDependencyKey {
          public static var testValue: _$GreatTool {
              _$GreatTool()
          }
      }

      extension _$GreatTool: DependencyKey {
          public static var liveValue: _$GreatTool {
              let underLive = Implements()
              return _$GreatTool.from(underLive)
          }

          public static func from(_ live: Implements) -> _$GreatTool {
              _$GreatTool(foo: {
          await live.foo(a: $0)
                  }, hoge: {
          try await live.hoge($0)
                  }, yes: {
          await live.yes(&$0)
                  })
          }
      }
      """
    }
  }
}
