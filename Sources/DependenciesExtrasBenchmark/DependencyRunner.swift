import DependenciesExtrasMacros
import Foundation

extension DependencyValues {
    #DependencyValueRegister(of: GreatTool.self, into: "great")
}

@DependencyProtocolClient
protocol GreatTool {
    func hoge()
    func foo(a: String) -> String
}

@DependencyLiveDepConformance(of: GreatTool.self)
struct XCX: GreatTool {
    func foo(a: String) -> String { "" }
    func hoge() {}
}

struct Runner {
    @Dependency(\.great) var great
    func run() async throws {
        let new = withDependencies {
            $0.context = .live
        } operation: {
            great
        }
        new.hoge()
    }
}
