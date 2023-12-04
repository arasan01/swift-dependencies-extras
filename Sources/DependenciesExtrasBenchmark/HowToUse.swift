import DependenciesExtrasMacros
import Foundation

@DependencyProtocolClient(implemented: ProtocolPersistentImpl.self)
protocol ProtocolPersistent: Sendable {
    func load(_ url: URL) throws -> Data
    func save(_ data: Data, _ url: URL) async throws -> Void
}

public final class ProtocolPersistentImpl: @unchecked Sendable, ProtocolPersistent {
    func load(_ url: URL) throws -> Data { try Data(contentsOf: url) }
    func save(_ data: Data, _ url: URL) async throws -> Void { try data.write(to: url) }
}

extension DependencyValues {
    #DependencyValueRegister(of: ProtocolPersistent.self, into: "protocolPersistent")
}

@available(macOS 13.0, *)
struct Runner {
    @Dependency(\.protocolPersistent) var protocolPersistent
    
    func run() async throws {
        do {
            let new = withDependencies {
                $0.protocolPersistent.save = { data, url in debugPrint(data, url) }
            } operation: {
                protocolPersistent
            }
            try await new.save("struct".data(using: .utf8)!, URL.documentsDirectory.appendingPathComponent(UUID().uuidString, conformingTo: .text))
        }
    }
}

@main @available(macOS 13.0, *)
struct MainApp {
    static func main() async throws {
        let runner = Runner()
        try await runner.run()
    }
}
