import DependenciesExtrasMacrosPlugin
import MacroTesting
import XCTest

final class DependenciesExtrasMacrosPluginTests: XCTestCase {
  override func invokeTest() {
    withMacroTesting(
      isRecording: true,
      macros: [
        DependencyProtocolClientMacro.self, DependencyConformanceMacro.self,
        DependencyValueRegisterMacro.self, DependencyImplementClientMacro.self,
      ]
    ) { super.invokeTest() }
  }

  func testBasics() {
    assertMacro {
      """
      @DependencyProtocolClient
      public protocol SimpleInterfaceProtocol {
          func execute(arg: String) -> String
      }

      public struct SimpleImpl: SimpleInterfaceProtocol {
          public func execute(arg: String) -> String {
              return "simple"
          }
      }
      """
    } expansion: {
      """
      public protocol SimpleInterfaceProtocol {
          func execute(arg: String) -> String
      }
      @DependencyClient
      public struct _$SimpleInterface {
          var todo: @Sendable (_ id: Int) -> Int = { _ in
              .previewValue(0)
          }
      }

      public struct SimpleImpl: SimpleInterfaceProtocol {
          public func execute(arg: String) -> String {
              return "simple"
          }
      }

      extension _$SimpleInterface: TestDependencyKey {
          public static var testValue: _$SimpleInterface {
              _$SimpleInterface()
          }
      }
      """
    }
  }

  func testRegister() {
    assertMacro {
      """
      extension DependencyValues {
          #DependencyValueRegister(of: SimpleInterfaceProtocol.self, into: "chan")
      }

      @DependencyProtocolClient
      public protocol SimpleInterfaceProtocol {
          func execute(arg: String) -> String
      }

      public struct SimpleImpl: SimpleInterfaceProtocol {
          public func execute(arg: String) -> String {
              return "simple"
          }
      }
      """
    } expansion: {
      """
      extension DependencyValues {
          public var chan: _$SimpleInterface {
              get { self[_$SimpleInterface.self] }
              set { self[_$SimpleInterface.self] = newValue }
          }
      }
      public protocol SimpleInterfaceProtocol {
          func execute(arg: String) -> String
      }
      @DependencyClient
      public struct _$SimpleInterface {
          var todo: @Sendable (_ id: Int) -> Int = { _ in
              .previewValue(0)
          }
      }

      public struct SimpleImpl: SimpleInterfaceProtocol {
          public func execute(arg: String) -> String {
              return "simple"
          }
      }

      extension _$SimpleInterface: TestDependencyKey {
          public static var testValue: _$SimpleInterface {
              _$SimpleInterface()
          }
      }
      """
    }
  }

  func testImplement() {
    assertMacro {
      """
      extension DependencyValues {
          #DependencyValueRegister(of: SimpleInterfaceProtocol.self, into: "chan")
      }

      @DependencyProtocolClient
      public protocol SimpleInterfaceProtocol {
          func foo()
          func gem(_ gotcha: Bool) -> Void
          func bar(arg: String)
          func haa(arg: Int) -> String
          func good(a: Int, b: Int) -> Int
      }

      @DependencyImplementClient(of: SimpleInterfaceProtocol.self)
      public struct SimpleImpl: SimpleInterfaceProtocol {
          public func execute(arg: String) -> String {
              return "simple"
          }
      }
      """
    } expansion: {
      """
      extension DependencyValues {
          public var chan: _$SimpleInterface {
              get { self[_$SimpleInterface.self] }
              set { self[_$SimpleInterface.self] = newValue }
          }
      }
      public protocol SimpleInterfaceProtocol {
          func foo()
          func gem(_ gotcha: Bool) -> Void
          func bar(arg: String)
          func haa(arg: Int) -> String
          func good(a: Int, b: Int) -> Int
      }
      @DependencyClient
      public struct _$SimpleInterface {
          public var foo: @Sendable () -> Void
          public var gem: @Sendable () -> Void
          public var bar: @Sendable () -> Void
          public var haa: @Sendable () -> String = { _ in
              .mock
          }
          public var good: @Sendable () -> Int = {
              _
              _ in
              .mock
          }
      }
      public struct SimpleImpl: SimpleInterfaceProtocol {
          public func execute(arg: String) -> String {
              return "simple"
          }
      }

      extension _$SimpleInterface: TestDependencyKey {
          public static var testValue: _$SimpleInterface {
              _$SimpleInterface()
          }
      }

      extension _$SimpleInterface: DependencyKey {
          public static var liveValue: _$SimpleInterface {
              _$SimpleInterface(fixme: fixme)
          }
      }
      """
    }
  }
}
