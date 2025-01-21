// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GDSLogging",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "GDSLogging", targets: ["GDSLogging"]),
        .library(name: "HTTPLogging", targets: ["HTTPLogging"]),
        .library(name: "GAnalytics", targets: ["GAnalytics"]),
        .library(name: "GDSAnalytics", targets: ["GDSAnalytics"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .upToNextMajor(from: "11.1.0")
        ),
        .package(
            url: "https://github.com/govuk-one-login/mobile-ios-networking.git",
            .upToNextMajor(from: "3.0.0")
        )
    ],
    targets: [
        .target(name: "GDSLogging",
                exclude: ["README.md"],
                swiftSettings: [
                    .define("DEBUG", .when(configuration: .debug))
                ]),
        .testTarget(name: "GDSLoggingTests",
                    dependencies: ["GDSLogging"]),
        
        .target(name: "HTTPLogging",
                dependencies: ["GDSLogging", .product(name: "Networking", package: "mobile-ios-networking")],
                exclude: ["README.md"],
                swiftSettings: [
                    .define("DEBUG", .when(configuration: .debug))
                ]),
        .testTarget(name: "HTTPLoggingTests",
                    dependencies: [
                        "HTTPLogging",
                        .product(name: "MockNetworking", package: "mobile-ios-networking")
                    ]),
        
        .target(name: "GAnalytics",
                dependencies: [
                    "GDSLogging",
                    .product(name: "FirebaseAnalyticsWithoutAdIdSupport", package: "firebase-ios-sdk"),
                    .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk")
                ],
                exclude: ["README.md"],
                swiftSettings: [
                    .define("DEBUG", .when(configuration: .debug))
                ]),
        .testTarget(name: "GAnalyticsTests",
                    dependencies: ["GAnalytics"]),
        
        .target(name: "GDSAnalytics",
                exclude: ["README.md"]),
        .testTarget(name: "GDSAnalyticsTests",
                    dependencies: ["GDSAnalytics"])
    ]
)
