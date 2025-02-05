// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Logging",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "Logging", targets: ["Logging"]),
        .library(name: "HTTPLogging", targets: ["HTTPLogging"]),
        .library(name: "GAnalytics", targets: ["GAnalytics"]),
        .library(name: "GDSAnalytics", targets: ["GDSAnalytics"]),
        .library(name: "AnalyticsBridge", targets: ["AnalyticsBridge"])
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
        .target(name: "Logging",
                exclude: ["README.md"],
                swiftSettings: [
                    .define("DEBUG", .when(configuration: .debug))
                ]),
        .testTarget(name: "LoggingTests",
                    dependencies: ["Logging"]),
        
        .target(name: "HTTPLogging",
                dependencies: ["Logging", .product(name: "Networking", package: "mobile-ios-networking")],
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
                    "Logging",
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
                dependencies: [
                    "Logging",
                    ],
                exclude: ["README.md"]),
        .testTarget(name: "GDSAnalyticsTests",
                    dependencies: ["GDSAnalytics"]),
        .target(name: "AnalyticsBridge",
                dependencies: [
                    "Logging",
                    "GDSAnalytics"
                ])
    ]
)
