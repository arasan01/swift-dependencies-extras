//import DependenciesExtrasMacros
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
