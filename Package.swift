// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ShareThatTo",
    platforms: [
        .iOS(.v10),
        .tvOS(.v10)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ShareThatTo",
            targets: ["ShareThatTo", "UGCGenerator"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/venmo/DVR", from: "2.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ShareThatTo",
            dependencies: [
            ],
            path: "Sources/ShareThatTo", resources: [
                .copy("Assets")
            ]),
        .target(
            name: "UGCGenerator",
            path: "Sources/UGCGenerator"
        ),
        .testTarget(
            name: "ShareThatToTests",
            dependencies: ["ShareThatTo", "DVR"],
            resources: [
              // Copy Tests/ExampleTests/Resources directories as-is.
              // Use to retain directory structure.
              // Will be at top level in bundle.
              .copy("Fixtures"),
            ]),
    ]
)
