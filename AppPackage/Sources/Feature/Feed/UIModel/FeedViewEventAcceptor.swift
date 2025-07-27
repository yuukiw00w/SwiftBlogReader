import Foundation
import SwiftData
internal import XMLKit

@MainActor
public struct FeedViewEventAcceptor {
    private let updateViewState: (UpdateFeedViewStateEvent) -> Void
    private let repository: FeedRepository

    public init(
        repository: FeedRepository,
        updateViewState: @escaping (UpdateFeedViewStateEvent) -> Void,
    ) {
        self.repository = repository
        self.updateViewState = updateViewState
    }

    @discardableResult
    public func onAppear() -> Task<Void, Never> {
        updateViewState(.onStartFetching)
        return Task {
            do {
                let cached: [FeedEntity] =
                    (try? repository.fetchCacheItems()) ?? []
                if cached.isEmpty {
                    let appendFeed = try await repository.fetchNonCachedFeed(
                        cached: [])
                    updateViewState(.onFetchedFeed(appendFeed))
                } else {
                    updateViewState(.onFetchedFeed(cached))
                    let appendItems = try await repository.fetchNonCachedFeed(
                        cached: cached,
                    )
                    if !appendItems.isEmpty {
                        updateViewState(.onNewFeedAppended(appendItems))
                    }
                }
            } catch {
                updateViewState(.onFetchFailed(error))
            }
        }
    }

    public func onRefresh() async {
        updateViewState(.onStartFetching)

        do {
            let cached: [FeedEntity] = (try? repository.fetchCacheItems()) ?? []
            try await repository.fetchNonCachedFeed(cached: cached)
            let fetched: [FeedEntity] =
                (try? repository.fetchCacheItems()) ?? []
            updateViewState(.onRefetchedFeed(fetched))
        } catch {
            updateViewState(.onRefetchFailed(error))
        }
    }

    public func onItemSelected(_ entity: FeedEntity?) {
        guard let entity else {
            return
        }
        var newEntity = entity
        newEntity.isRead = true
        try? repository.markRead(entity: entity)
        updateViewState(.onItemSelected(newEntity))
    }
}
