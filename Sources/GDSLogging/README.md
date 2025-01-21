# Logging

A general purpose interface for logging fire-and-forget events for analytics purposes.

Example implementations for the interfaces in this module can be found in the [HTTPLogging](../HTTPLogging) and [GAnalytics](../GAnalytics) directories in this repository.

## Installation

To use Logging in a project using Swift Package Manager:

1. Add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/govuk-one-login/mobile-ios-logging", .upToNextMajor(from: "1.0.0")),
```

2. Add `Logging` as a dependency for your target:

```swift
.target(name: "MyTarget", dependencies: [
    .product(name: "Logging", package: "mobile-ios-logging"),
    "AnotherModule"
]),
```

3. Add `import GDSLogging` in your source code.

## Package description

The `Logging` module contains protocols that can be used for a variety of implementation of analytics services.

### Tracking of user action events

We support basic logging using `LoggingService`, which is great for simple analytics implementations that simply allow tracking of events.
The `LoggableEvent` is available for logging events to the `AnalyticsService` and `LoggingService`.

We recommend utilising enumerations for managing event types within your analytics implementations:

```swift
enum MyAppEvents: String, LoggableEvent {
    case buttonTapped
    case linkAccessed
}
```

These can be logged directly, optionally providing additional data via parameters:

```swift
let logger: LoggingService

logger.trackEvent(
    MyAppEvents.buttonTapped, 
    parameters: ["button_name": "continue"]
)
```

### Tracking of screen views

`AnalyticsService` extends the `LoggingService` to allow for additional functionality, such as screen tracking.

Screen that are to be tracked must have a clearly defined type (class), which helps to identify view controllers that are reused across different pieces of functionality, for example:

```swift
enum ScreenTypes: String, ScreenType {
    case welcome = "WELCOME_SCREEN"
    case error = "ERROR_SCREEN"
}
```

Conform to the `LoggableScreenV2` protocol to track a specific screen with the `AnalyticsService`.

```swift
struct ErrorScreen: LoggableScreenV2 {
    let type: ScreenType = ScreenTypes.error
    let name: String
}
```

You can then track the screen appearance in the `viewDidAppear` lifecycle method:

```swift
final class NetworkErrorViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let screen = ErrorScreen(name: "not connected to the internet")
        analyticsService.trackScreen(screen, parameters: [:])
    }
}
```

You can even conform your view controller directly to the `LoggableScreenV2` protocol:

```swift
import UIKit

final class MyViewController: UIViewController {
    let analyticsService: AnalyticsService

    init(analyticsService: AnalyticsService) {
        self.title = "Screen Title"
        self.analyticsService = analyticsService
        super.init()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.trackScreen(self, parameters: [:])
    }
}

extension MyViewController: LoggableScreenV2 {
    var name: String { title! }
    var type: ScreenType { ScreenTypes.error }
}

```

### Requesting user permission for analytics

It is important to request a user’s permission before tracking them with analytics.
Use the `AnalyticsPreferenceStore` for this purpose.

```swift
let preferenceStore: AnalyticsPreferenceStore
```

The store lets you track whether a user has previously accepted analytics.

```swift
func userProvidedConsentForAnalytics() {
    preferenceStore.hasAcceptedAnalytics = true
}
```

You can also subscribe to changes in the user’s choice.

```swift
for await isConsentProvided in preferenceStore.stream() {
    // react to changes in the user’s consent to analytics
}
```

A default implementation using `UserDefaults` is provided as part of this package.

```swift
let preferenceStore: AnalyticsPreferenceStore = UserDefaultsPreferenceStore()
```

