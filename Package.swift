// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FuzzyMatchingSwift",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "FuzzyMatchingSwift",
            targets: ["FuzzyMatchingSwift"]
        )
    ],
    targets: [
        .target(
            name: "FuzzyMatchingSwift",
            path: "FuzzyMatchingSwift/Classes",
            publicHeadersPath: ".",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "FuzzyMatchingSwiftTests",
            dependencies: ["FuzzyMatchingSwift"],
            path: "Example/Tests",
            resources: [
                .copy("desolation_row.txt")
            ]
        )
    ]
)
