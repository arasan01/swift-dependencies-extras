// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "swift-dependencies-extras",
  platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6)],
  products: [.library(name: "DependenciesExtrasMacros", targets: ["DependenciesExtrasMacros"])],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.1.0"),
    .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.2.0"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.0.0"),
    .package(url: "https://github.com/google/swift-benchmark", from: "0.1.0"),
  ],
  targets: [
    .executableTarget(
      name: "DependenciesExtrasBenchmark",
      dependencies: [
        "DependenciesExtrasMacros", .product(name: "Benchmark", package: "swift-benchmark"),
      ],
      swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
    ),
    .target(
      name: "DependenciesExtrasMacros",
      dependencies: [
        "DependenciesExtrasMacrosPlugin",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]),
    .macro(
      name: "DependenciesExtrasMacrosPlugin",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]),
    .testTarget(
      name: "DependenciesExtrasMacrosPluginTests",
      dependencies: [
        "DependenciesExtrasMacrosPlugin",
        .product(name: "MacroTesting", package: "swift-macro-testing"),
      ]),
  ])

#if !os(Windows)
  // Add the documentation compiler plugin if possible
  package.dependencies.append(
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"))
#endif
