import Foundation

let s = DispatchSemaphore(value: 0)

Task {
    do { try await Runner().run() }
    catch {}
    s.signal()
}

s.wait()
