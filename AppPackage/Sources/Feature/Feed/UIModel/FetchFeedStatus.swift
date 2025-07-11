public import Foundation

public enum FetchFeedStatus {
    case failed(any Error)
    case fetched(Date)
    case fetching
    case idle
}
