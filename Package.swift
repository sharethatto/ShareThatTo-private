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
            targets: ["ShareThatTo"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
//        .package(name: "SCSDKCreativeKit", url: "https://github.com/sharethatto/Snapchat-SPM", from: "1.0.0"),
        
//        .package(name: "SCSDKCreativeKit", url: "https://github.com/sharethatto/Snapchat-SPM", from: "master"),
        .package(url: "https://github.com/venmo/DVR", from: "2.0.0"),
        .package(name: "Facebook", url: "https://github.com/facebook/facebook-ios-sdk", from: "9.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ShareThatTo",
            dependencies: [
                .product(name: "FacebookShare", package: "Facebook"),
//                .product(name: "SCSDKCreativeKit", package: "SCSDKCreativeKit")
            ],
            resources: [
                .copy("Assets")
            ]),
        .testTarget(
            name: "ShareThatToTests",
            dependencies: ["ShareThatTo", "DVR"],
            resources: [
              // Copy Tests/ExampleTests/Resources directories as-is.
              // Use to retain directory structure.
              // Will be at top level in bundle.
              .copy("Fixtures"),
//              .copy("Assets"),
            ]),
    ]
)
