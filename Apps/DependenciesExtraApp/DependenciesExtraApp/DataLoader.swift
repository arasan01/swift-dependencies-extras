import Foundation
import DependenciesExtrasMacros

@DependencyClient
struct DataLoader: Sendable {
    var load: @Sendable (_ url: URL) -> Data = { _ in .init() }
}

extension DataLoader: DependencyKey {
    static var liveValue: DataLoader {
        @Dependency(\.underline) var underline
        
        return DataLoader { url in
            underline.call()
            return "data".data(using: .utf8)!
        }
    }
}

extension DataLoader: TestDependencyKey {
    static var testValue: DataLoader = .init()
}

@DependencyProtocolClient(implemented: WrappedDataLoaderImpl.self)
protocol WrappedDataLoader: Sendable {
    func load(url: URL) -> Data
}

public final class WrappedDataLoaderImpl: @unchecked Sendable, WrappedDataLoader {
    @Dependency(\.underline) var underline
    
    func load(url: URL) -> Data {
        underline.call()
        return "wrapped".data(using: .utf8)!
    }
}

@DependencyProtocolClient(implemented: UnderlineImpl.self)
protocol Underline: Sendable {
    func call()
}

public final class UnderlineImpl: Underline {
    func call() {
        print("live")
    }
}

extension DependencyValues {
    var dataLoader: DataLoader {
        get { self[DataLoader.self] }
        set { self[DataLoader.self] = newValue }
    }
    
    #DependencyValueRegister(of: WrappedDataLoader.self, into: "wrappedDataLoader")
    #DependencyValueRegister(of: Underline.self, into: "underline")
}
