# Logging

A Swift Package usable for HTTP logging and passing analytics to a third-party SDK, also included is an abstraction class for using Google's Firebase analytics platform.

## Installation

To use this Logging package in a project using Swift Package Manager:

1. Add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/govuk-one-login/mobile-ios-logging", from: "1.0.0"),
```

2. Add any of `Logging`, `GAnalytics`, `HTTPLogging` and/or `GDSAnalytics` as a dependencies for your target:

```swift
.target(name: "MyTarget", dependencies: [
  .product(name: "Logging", package: "di-mobile-ios-logging"),
  .product(name: "GAnalytics", package: "di-mobile-ios-logging"),
  .product(name: "HTTPLogging", package: "di-mobile-ios-logging"),
  .prodcut(name: "GDSAnalytics", package: "di-mobile-ios-logging")
]),
```

3. Add `import GDSLogging`, `import GAnalytics`, `import HTTPLogging` and/or `import GDSAnalytics` into your source code where necessary.

## Package description

For individual descriptions of the modules in this package, head to the README files for each:

[Logging](./Sources/Logging/README.md)

[GAnalytics](./Sources/GAnalytics/README.md)

[HTTPLogging](./Sources/HTTPLogging/README.md)

[GDSAnalytics](./Sources/GDSAnalytics/README.md)
