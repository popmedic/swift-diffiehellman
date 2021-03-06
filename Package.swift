// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "DiffieHellmanSecurity",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "DiffieHellmanSecurity",
            targets: [
                "DiffieHellmanSecurity"
            ]
        ),
        .executable(
            name: "dhdigest",
            targets: ["dhdigest"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser",
                 from: "0.2.0")
    ],
    targets: [
        .target(
            name: "DiffieHellmanSecurity",
            dependencies: []
        ),
        .testTarget(
            name: "DiffieHellmanSecurityTests",
            dependencies: [
                "DiffieHellmanSecurity"
            ],
            resources: [
                .process("TestData")
            ]
        ),
        .target(
            name: "dhdigest",
            dependencies: [
                "DiffieHellmanSecurity",
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                )
            ]
        )
    ]
)
