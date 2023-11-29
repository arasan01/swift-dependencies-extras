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

    func testBasics() {
        assertMacro {
            """
            @DependencyProtocolClient(implemented: SimpleImpl.self)
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
            public struct _$SimpleInterfaceProtocol {
                public var execute: @Sendable (_ arg: String) -> String = { (_) in
                    unimplemented("execute")
                }
            }

            public struct SimpleImpl: SimpleInterfaceProtocol {
                public func execute(arg: String) -> String {
                    return "simple"
                }
            }

            extension _$SimpleInterfaceProtocol: TestDependencyKey {
                public static var testValue: _$SimpleInterfaceProtocol {
                    _$SimpleInterfaceProtocol()
                }
            }

            extension _$SimpleInterfaceProtocol: DependencyKey {
                public static var liveValue: _$SimpleInterfaceProtocol {
                    _$SimpleInterfaceProtocol.from(SimpleImpl())
                }

                public static func from(_ native: SimpleImpl) -> _$SimpleInterfaceProtocol {
                    _$SimpleInterfaceProtocol(execute: native.execute(arg:))
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

            @DependencyProtocolClient(implemented: SimpleImpl.self)
            public protocol SimpleInterfaceProtocol {
                func execute(arg: String) -> String
                var body: some View { get }
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
                public var chan: _$SimpleInterfaceProtocol {
                    get { self[_$SimpleInterfaceProtocol.self] }
                    set { self[_$SimpleInterfaceProtocol.self] = newValue }
                }
            }
            public protocol SimpleInterfaceProtocol {
                func execute(arg: String) -> String
                var body: some View { get }
            }
            @DependencyClient
            public struct _$SimpleInterfaceProtocol {
                public var execute: @Sendable (_ arg: String) -> String = { (_) in
                    unimplemented("execute")
                }
            }

            public struct SimpleImpl: SimpleInterfaceProtocol {
                public func execute(arg: String) -> String {
                    return "simple"
                }
            }

            extension _$SimpleInterfaceProtocol: TestDependencyKey {
                public static var testValue: _$SimpleInterfaceProtocol {
                    _$SimpleInterfaceProtocol()
                }
            }

            extension _$SimpleInterfaceProtocol: DependencyKey {
                public static var liveValue: _$SimpleInterfaceProtocol {
                    _$SimpleInterfaceProtocol.from(SimpleImpl())
                }

                public static func from(_ native: SimpleImpl) -> _$SimpleInterfaceProtocol {
                    _$SimpleInterfaceProtocol(execute: native.execute(arg:))
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

            @DependencyProtocolClient(implemented: SimpleImpl.self)
            public protocol SimpleInterfaceProtocol {
                func foo()
                func heh() -> String
                func gem(_ gotcha: Bool) -> Void
                func bar(arg: String)
                func haa(arg: Int) -> String
                func good(_ a: Int, b: Int) -> Int
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
                public var chan: _$SimpleInterfaceProtocol {
                    get { self[_$SimpleInterfaceProtocol.self] }
                    set { self[_$SimpleInterfaceProtocol.self] = newValue }
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
            public struct _$SimpleInterfaceProtocol {
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

            extension _$SimpleInterfaceProtocol: TestDependencyKey {
                public static var testValue: _$SimpleInterfaceProtocol {
                    _$SimpleInterfaceProtocol()
                }
            }

            extension _$SimpleInterfaceProtocol: DependencyKey {
                public static var liveValue: _$SimpleInterfaceProtocol {
                    _$SimpleInterfaceProtocol.from(SimpleImpl())
                }

                public static func from(_ native: SimpleImpl) -> _$SimpleInterfaceProtocol {
                    _$SimpleInterfaceProtocol(foo: native.foo, heh: native.heh, gem: native.gem(_:), bar: native.bar(arg:), haa: native.haa(arg:), good: native.good(_:b:))
                }
            }
            """
        }
    }
}
