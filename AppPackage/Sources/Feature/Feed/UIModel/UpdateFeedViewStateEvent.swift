import Foundation

public enum UpdateFeedViewStateEvent {
    case onFetchedFeed([FeedEntity])
    case onFetchFailed(any Error)
    case onItemSelected(FeedEntity)
    case onNewFeedAppended([FeedEntity])
    case onRefetchedFeed([FeedEntity])
    case onRefetchFailed(any Error)
    case onSetSearchText(String)
    case onStartFetching
}
