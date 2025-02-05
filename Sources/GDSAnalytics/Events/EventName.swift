import Logging

public enum EventName: String {
    case navigation
    case formResponse = "form_response"
    case popup
}

extension EventName: LoggableEvent { }
