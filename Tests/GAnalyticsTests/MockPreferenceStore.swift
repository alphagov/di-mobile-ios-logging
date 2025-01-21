import GDSLogging

final class MockPreferenceStore: AnalyticsPreferenceStore {
    private(set) var subscribers: [AsyncStream<Bool>.Continuation] = []
    
    var hasAcceptedAnalytics: Bool?
    
    func stream() -> AsyncStream<Bool> {
        AsyncStream {
            subscribers.append($0)
        }
    }
}
