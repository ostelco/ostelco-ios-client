// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let runnerName = "SPM"
let frameworkName = "Core"

let package = Package(
    name: runnerName,
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .executable(
            name: runnerName,
            targets: [runnerName]
        ),
        .library(
            name: frameworkName,
            targets: [frameworkName]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(
            url: "https://github.com/JohnSundell/Files.git",
            .upToNextMinor(from: "3.1.0")
        ),
        .package(
            url: "https://github.com/JohnSundell/ShellOut.git",
            .upToNextMinor(from: "2.2.0")
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: runnerName,
            dependencies: ["Core"]
        ),
        .target(
            name: frameworkName,
            dependencies: ["Files", "ShellOut"]
        ),
        .testTarget(
            name: "\(runnerName)Tests",
            dependencies: ["SPM"]
        ),
    ]
)
