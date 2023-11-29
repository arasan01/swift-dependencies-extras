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
          public var execute: @Sendable (_ arg: String) -> String = { (_) in
              unimplemented("execute")
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
          public var execute: @Sendable (_ arg: String) -> String = { (_) in
              unimplemented("execute")
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
          func heh() -> String
          func gem(_ gotcha: Bool) -> Void
          func bar(arg: String)
          func haa(arg: Int) -> String
          func good(_ a: Int, b: Int) -> Int
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
          func heh() -> String
          func gem(_ gotcha: Bool) -> Void
          func bar(arg: String)
          func haa(arg: Int) -> String
          func good(_ a: Int, b: Int) -> Int
      }
      @DependencyClient
      public struct _$SimpleInterface {
          public var foo: @Sendable () -> Void
          public var heh: @Sendable () -> String = { () in
              unimplemented("heh")
          }
          public var gem: @Sendable (_: Bool) -> Void
          public var bar: @Sendable (_ arg: String) -> Void
          public var haa: @Sendable (_ arg: Int) -> String = { (_) in
              unimplemented("haa")
          }
          public var good: @Sendable (_: Int, _ b: Int) -> Int = { (_, _) in
              unimplemented("good")
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
