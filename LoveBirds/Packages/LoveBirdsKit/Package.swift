// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LoveBirdsKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(name: "LoveBirdsKit", targets: ["LoveBirdsKit"])
    ],
    targets: [
        .target(
            name: "LoveBirdsKit",
            path: "Sources/LoveBirdsKit",
            resources: []
        ),
        .testTarget(
            name: "LoveBirdsKitTests",
            dependencies: ["LoveBirdsKit"],
            path: "Tests/LoveBirdsKitTests"
        )
    ]
)
