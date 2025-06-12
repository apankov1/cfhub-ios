// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CFHubIOS",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "CFHubApp",
            targets: ["CFHubApp"]
        ),
        .library(
            name: "CFHubCore",
            targets: ["CFHubCore"]
        ),
        .library(
            name: "CFHubCloudflare",
            targets: ["CFHubCloudflare"]
        ),
        .library(
            name: "CFHubGitHub",
            targets: ["CFHubGitHub"]
        ),
        .library(
            name: "CFHubClient",
            targets: ["CFHubClient"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-testing.git", from: "0.4.0")
    ],
    targets: [
        // MARK: - Main App Target
        .target(
            name: "CFHubApp",
            dependencies: [
                "CFHubCore",
                "CFHubCloudflare",
                "CFHubGitHub",
                "CFHubClient"
            ],
            path: "Sources/CFHubApp",
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        // MARK: - Core Engine & Types
        .target(
            name: "CFHubCore",
            dependencies: ["CFHubClient"],
            path: "Sources/CFHubCore",
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        // MARK: - Cloudflare Integration
        .target(
            name: "CFHubCloudflare",
            dependencies: [
                "CFHubCore",
                "CFHubClient"
            ],
            path: "Sources/Integrations/CFHubCloudflare",
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        // MARK: - GitHub Integration
        .target(
            name: "CFHubGitHub",
            dependencies: [
                "CFHubCore",
                "CFHubClient"
            ],
            path: "Sources/Integrations/CFHubGitHub",
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        // MARK: - HTTP Client
        .target(
            name: "CFHubClient",
            dependencies: [],
            path: "Sources/CFHubClient",
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        // MARK: - Test Targets
        .testTarget(
            name: "CFHubAppTests",
            dependencies: [
                "CFHubApp",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/CFHubAppTests"
        ),
        .testTarget(
            name: "CFHubCoreTests",
            dependencies: [
                "CFHubCore",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/CFHubCoreTests"
        ),
        .testTarget(
            name: "CFHubCloudflareTests",
            dependencies: [
                "CFHubCloudflare",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/Integrations/CFHubCloudflareTests"
        ),
        .testTarget(
            name: "CFHubGitHubTests",
            dependencies: [
                "CFHubGitHub",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/Integrations/CFHubGitHubTests"
        ),
        .testTarget(
            name: "CFHubClientTests",
            dependencies: [
                "CFHubClient",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/CFHubClientTests"
        )
    ]
)