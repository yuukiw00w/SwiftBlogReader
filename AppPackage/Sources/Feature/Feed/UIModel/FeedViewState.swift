import Foundation
public import Observation

@MainActor
@Observable
public final class FeedViewState {
    public var filteredFeed: [FeedEntity] {
        if searchText.isEmpty {
            feed
        } else {
            feed.filter { item in
                item.title.lowercased().contains(searchText.lowercased())
            }
        }
    }

    public private(set) var feed: [FeedEntity] = (0 ..< 30).map {
        .placeholder(index: $0)
    }

    public private(set) var shouldShowPlaceholder: Bool = true
    public private(set) var fetchStatus: FetchFeedStatus = .idle
    public var isFetching: Bool {
        switch fetchStatus {
        case .fetching:
            true

        default:
            false
        }
    }

    public private(set) var selected: FeedEntity?
    public private(set) var searchText: String = ""

    public init() {}

    public func update(by event: UpdateFeedViewStateEvent) {
        switch event {
        case .onStartFetching:
            fetchStatus = .fetching

        case let .onFetchedFeed(feed):
            self.feed = feed
            shouldShowPlaceholder = false
            fetchStatus = .fetched(.now)

        case let .onRefetchedFeed(feed):
            if feed != self.feed {
                self.feed = feed
            }
            shouldShowPlaceholder = false
            fetchStatus = .fetched(.now)

        case let .onFetchFailed(error):
            feed = []
            shouldShowPlaceholder = false
            fetchStatus = .failed(error)

        case let .onRefetchFailed(error):
            fetchStatus = .failed(error)

        case let .onItemSelected(selected):
            self.selected = selected
            if let index = feed.firstIndex(where: { $0.id == selected.id }) {
                feed[index] = selected
            }

        case let .onSetSearchText(text):
            searchText = text

        case let .onNewFeedAppended(newItems):
            // 新着を先頭に追加し重複を排除
            let existingIDs = Set(feed.map(\.id))
            let filtered = newItems.filter { !existingIDs.contains($0.id) }
            feed = filtered + feed
        }
    }
}
