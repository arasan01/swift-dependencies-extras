# Dependencies Extras

Libraries that make swift-dependencies even more useful

## Now on provide.

### Dependencies Extras Macros

Automatically rewrite the conventional design consisting of Protocol, Class, and Struct based on swift-dependencies in PointFree style, allowing rewriting of each implemented function one by one.

## Table of Contents

* [Overview](#overview)
* [Quick start](#quick-start)
* [Examples](#examples)
* [Documentation](#documentation)
* [Installation](#installation)
* [Community](#community)
* [Extensions](#extensions)
* [Alternatives](#alternatives)
* [License](#license)


## Overview

Look at this first. Swift The power of Macro makes it possible to cut out and rewrite a single function, even if it is implemented in a protocol.

```swift
import DependenciesExtrasMacros
import Foundation

extension DependencyValues {
    #DependencyValueRegister(of: GreatTool.self, into: "great")
}

@DependencyProtocolClient(implemented: Implements.self)
public protocol GreatTool {
    func foo(a: Int) -> Int
    func hoge(_ b: Double) -> Double
    func yes() -> Bool
}

public class Implements: GreatTool {
    var x = 1
    var y = 2.0
    @Sendable public func yes() -> Bool { true }
    @Sendable public func foo(a: Int) -> Int { x }
    @Sendable public func hoge(_ b: Double) -> Double { y }
}

struct Runner {
    func run() async throws {
        @Dependency(\.great) var great
        let new = withDependencies {
            $0.great.foo = { @Sendable _ in 42 }
            $0.great.yes = { @Sendable in false }
        } operation: {
            great
        }
        assert(new.yes() == false, "missing override")
        assert(new.foo(a: 0) == 42, "missing override")
        assert(new.hoge(0) == 2.0, "missing macro")
        
        print("Great !! Nice work.")
    }
}
```


## Quick

TODO

## Examples

TODO

## Documentation

TODO

## Installation

TODO

## Community

TODO

## Extensions

TODO


## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.

