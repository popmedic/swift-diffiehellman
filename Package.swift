// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "DiffieHellmanSecurity",
    products: [
        .library(
            name: "DiffieHellmanSecurity",
            targets: [
                "DiffieHellmanSecurity"
            ]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DiffieHellmanSecurity",
            dependencies: []
        ),
        .testTarget(
            name: "DiffieHellmanSecurityTests",
            dependencies: [
                "DiffieHellmanSecurity"
            ]
        )
    ]
)
