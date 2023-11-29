import DependenciesExtrasMacros

public struct MyValue {}

@DependencyClient public struct SimpleInterface {
  public var foo: @Sendable () -> Void
  public var heh: @Sendable () -> String = { () in unimplemented("heh") }
  public var gem: @Sendable (_: Bool) -> Void
  public var bar: @Sendable (_ arg: String) -> Void
  public var haa: @Sendable (_ arg: Int) -> MyValue = { (_) in
    unimplemented("haa")
  }
  public var good: @Sendable (_: Int, _ b: Int) -> Int = { (_, _) in
    unimplemented("good")
  }
}

extension SimpleInterface: TestDependencyKey {
  public static var testValue: SimpleInterface { SimpleInterface() }
}

extension DependencyValues {
  var simple: SimpleInterface {
    get { self[SimpleInterface.self] }
    set { self[SimpleInterface.self] = newValue }
  }
}

struct Runner {
  @Dependency(\.simple) var simple
  func run() {
    let new = withDependencies {
      $0.simple.foo = { @Sendable in print("runned") }
      $0.simple.bar = { @Sendable a in print(a) }
    } operation: {
      simple
    }
    new.foo()
    new.bar(arg: "new")
    _ = new.haa(arg: 0)
  }
}

Runner().run()

//
//@DependencyProtocolClient
//public protocol GreatDesignedInteractor {
//    func hoge()
//}
//
//
//extension DependencyValues {
//    #DependencyValueRegister(of: GreatDesignedInteractor.self, into: "greatDesignedInteractor")
//}
//
//
//struct S {
//    @Dependency(\.greatDesignedInteractor) var greatDesignedInteractor
//
//    func hoge() {
//        let value = greatDesignedInteractor.todo(id: 100)
//        print(value)
//    }
//}
//
//let s = withDependencies {
//    $0.context = .live
//} operation: {
//    S()
//}
//
//s.hoge()
//
//
