// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

enum Target: String {
    case api = "API"
    case feature = "Feature"
}

let defaultSwiftSettings: [PackageDescription.SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
]

let package = Package(
    name: "AppPackage",
    platforms: [
        .macOS(.v26), .iOS("18.6"), .visionOS(.v26), .tvOS(.v26),
        .watchOS(.v26),
    ],
    products: [
        .library(
            name: "AppLibrary",
            targets: [Target.feature.rawValue]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/nmdias/FeedKit", from: "10.1.3"),
    ],
    targets: [
        .target(
            name: Target.api.rawValue,
            dependencies: [
                "FeedKit"
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .target(
            name: Target.feature.rawValue,
            dependencies: [
                .target(name: Target.api.rawValue)
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .testTarget(
            name: "FeatureTests",
            dependencies: [
                .target(name: Target.feature.rawValue)
            ]
        ),
    ]
)
