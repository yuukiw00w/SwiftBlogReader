import Foundation
import SwiftData
import Testing

@testable import API
@testable import Feature

@MainActor
struct FeedViewEventAcceptorTests {
    private func makeInMemoryModelContainer() throws -> ModelContainer {
        try ModelContainer(
            for: FeedItem.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true),
        )
    }

    private func feedRepository(
        _ modelContext: ModelContext,
        _ entries: [FeedEntry] = [],
    ) -> FeedRepository {
        FeedRepository(
            modelContext: modelContext,
            feedFetcher: MockFeedFetcher(mockFetchSwiftOrgFeed: { entries }),
            htmlWrapper: HTMLAutoDarkModeWrapper(),
        )
    }

    private func makeFeedEntry(
        id: String = "1",
        title: String? = nil,
        link: String? = nil,
        updatedDate: Date = Date(timeIntervalSince1970: 12345),
        author: String? = nil,
        htmlContent: String? = nil,
    ) -> FeedEntry {
        FeedEntry(
            id: id,
            title: title == nil ? "title\(id)" : title!,
            link: link == nil
                ? URL(string: "https://example.com/\(id)")!
                : URL(string: link!)!,
            updatedDate: updatedDate,
            baseURL: link == nil
                ? URL(string: "https://example.com/\(id)")!
                : URL(string: link!)!,
            author: author,
            htmlContent: htmlContent ?? "html" + id,
        )
    }

    @Test func onAppear_新しい順でitemsがセットされる() async throws {
        let state = FeedViewState()
        var updateEvents: [UpdateFeedViewStateEvent] = []

        let container = try makeInMemoryModelContainer()
        let context = container.mainContext
        let entry1 = makeFeedEntry(
            id: "1",
            updatedDate: Date(timeIntervalSince1970: 1),
        )
        let entry2 = makeFeedEntry(
            id: "4",
            updatedDate: Date(timeIntervalSince1970: 4),
        )
        let entry3 = makeFeedEntry(
            id: "3",
            updatedDate: Date(timeIntervalSince1970: 3),
        )
        let entry4 = makeFeedEntry(
            id: "10",
            updatedDate: Date(timeIntervalSince1970: 10),
        )
        let entry5 = makeFeedEntry(
            id: "5",
            updatedDate: Date(timeIntervalSince1970: 5),
        )
        let repo = feedRepository(
            context,
            [entry1, entry2, entry3, entry4, entry5],
        )
        let eventAcceptor = FeedViewEventAcceptor(repository: repo) { event in
            state.update(by: event)
            updateEvents.append(event)
        }
        let task = eventAcceptor.onAppear()
        let result = await task.result
        let isSuccess = if case .success = result { true } else { false }
        #expect(isSuccess)
        #expect(state.feed[0].id == entry4.id)
        #expect(state.feed[1].id == entry5.id)
        #expect(state.feed[2].id == entry2.id)
        #expect(state.feed[3].id == entry3.id)
        #expect(state.feed[4].id == entry1.id)
        #expect(updateEvents.count == 2)
        let isStartFetch =
            if case .onStartFetching = updateEvents[0] { true } else { false }
        #expect(isStartFetch)
        let isFinishFetch =
            if case .onFetchedFeed = updateEvents[1] { true } else { false }
        #expect(isFinishFetch)
    }

    @Test func onAppear_取得したものの0件だった場合itemsがセットされない() async throws {
        let state = FeedViewState()
        var updateEvents: [UpdateFeedViewStateEvent] = []

        let container = try makeInMemoryModelContainer()
        let context = container.mainContext
        let repo = feedRepository(context, [])
        let eventAcceptor = FeedViewEventAcceptor(repository: repo) { event in
            state.update(by: event)
            updateEvents.append(event)
        }
        let task = eventAcceptor.onAppear()
        let result = await task.result
        let isSuccess = if case .success = result { true } else { false }
        #expect(isSuccess)
        #expect(state.feed.isEmpty)
        #expect(updateEvents.count == 2)
        let isStartFetch =
            if case .onStartFetching = updateEvents[0] { true } else { false }
        #expect(isStartFetch)
        let isFinishFetch =
            if case .onFetchedFeed = updateEvents[1] { true } else { false }
        #expect(isFinishFetch)
    }

    @Test
    func
        onAppear_フィード取得失敗時にfetchStatusがfailedになりitemsが空になりupdateEventsが正しい順序で送られる()
        async throws
    {
        let state = FeedViewState()
        var updateEvents: [UpdateFeedViewStateEvent] = []
        let container = try makeInMemoryModelContainer()
        let context = container.mainContext
        // 失敗するfetcherを渡す
        let repo = FeedRepository(
            modelContext: context,
            feedFetcher: MockFeedFetcher(mockFetchSwiftOrgFeed: {
                throw URLError(.badServerResponse)
            }),
            htmlWrapper: HTMLAutoDarkModeWrapper(),
        )
        let eventAcceptor = FeedViewEventAcceptor(repository: repo) { event in
            state.update(by: event)
            updateEvents.append(event)
        }
        let task = eventAcceptor.onAppear()
        _ = await task.result
        // state.feedは空のまま
        #expect(state.feed.isEmpty)
        // fetchStatusが.failedである
        let isFailed =
            if case .failed = state.fetchStatus {
                true
            } else {
                false
            }
        #expect(isFailed)
        // updateEventsが2個で、順にonStartFetching, onFetchFailedである
        #expect(updateEvents.count == 2)
        let isStartFetch =
            if case .onStartFetching = updateEvents[0] { true } else { false }
        #expect(isStartFetch)
        let isFetchFailed =
            if case .onFetchFailed = updateEvents[1] { true } else { false }
        #expect(isFetchFailed)
    }

    @Test func onItemSelected_選択したitemがstateにセットされる() async throws {
        let state = FeedViewState()
        var updateEvents: [UpdateFeedViewStateEvent] = []
        let container = try makeInMemoryModelContainer()
        let context = container.mainContext
        let entry1 = makeFeedEntry(id: "1")
        let entry2 = makeFeedEntry(id: "2")
        let repo = feedRepository(context, [entry1, entry2])
        let eventAcceptor = FeedViewEventAcceptor(repository: repo) { event in
            state.update(by: event)
            updateEvents.append(event)
        }
        // まずonAppearでitemsをセット
        _ = await eventAcceptor.onAppear().result
        let selectItem = state.feed[1]
        eventAcceptor.onItemSelected(selectItem)
        // state.selectedがentry2になっていること
        #expect(state.selected?.id == selectItem.id)
        // updateEventsの最後がonItemSelectedでentry2であること
        let lastEvent = updateEvents.last
        let isItemSelected =
            if case let .onItemSelected(item) = lastEvent {
                item.id == selectItem.id
            } else {
                false
            }
        #expect(isItemSelected)
    }

    @Test func onRefresh_新しいフィードでstateが更新される() async throws {
        let state = FeedViewState()
        var updateEvents: [UpdateFeedViewStateEvent] = []
        let container = try makeInMemoryModelContainer()
        let context = container.mainContext
        let entry1 = makeFeedEntry(
            id: "1",
            updatedDate: Date(timeIntervalSince1970: 1),
        )
        let entry2 = makeFeedEntry(
            id: "2",
            updatedDate: Date(timeIntervalSince1970: 2),
        )
        // 初回はentry1のみ
        var feedEntries = [entry1]
        let repo = FeedRepository(
            modelContext: context,
            feedFetcher: MockFeedFetcher(mockFetchSwiftOrgFeed: { feedEntries }),
            htmlWrapper: HTMLAutoDarkModeWrapper(),
        )
        let eventAcceptor = FeedViewEventAcceptor(repository: repo) { event in
            state.update(by: event)
            updateEvents.append(event)
        }
        // まずonAppearでentry1のみ
        _ = await eventAcceptor.onAppear().result
        #expect(state.feed.count == 1)
        #expect(state.feed[0].id == entry1.id)

        // フィード内容をentry2だけに差し替えてonRefresh
        feedEntries = [entry2]

        // onRefreshのupdateEventsだけテストするので一度removeする
        updateEvents.removeAll()
        await eventAcceptor.onRefresh()

        #expect(state.feed.count == 2)
        #expect(state.feed.contains(where: { $0.id == entry2.id }))

        #expect(updateEvents.count == 2)
        let isStartFetch =
            if case .onStartFetching = updateEvents[0] { true } else { false }
        #expect(isStartFetch)
        let isFetched =
            if case .onRefetchedFeed = updateEvents[1] { true } else { false }
        #expect(isFetched)
    }

    @Test func onAppear_fetcherが遅延した場合ローディング状態になる() async throws {
        let state = FeedViewState()
        var updateEvents: [UpdateFeedViewStateEvent] = []
        let container = try makeInMemoryModelContainer()
        let context = container.mainContext
        let entry1 = makeFeedEntry(id: "1")
        // 遅延するfetcher
        let repo = FeedRepository(
            modelContext: context,
            feedFetcher: MockFeedFetcher(mockFetchSwiftOrgFeed: {
                try await Task.sleep(nanoseconds: 300_000_000)
                return [entry1]
            }),
            htmlWrapper: HTMLAutoDarkModeWrapper(),
        )
        let eventAcceptor = FeedViewEventAcceptor(repository: repo) { event in
            state.update(by: event)
            updateEvents.append(event)
        }
        // onAppearを非同期で開始
        let task = eventAcceptor.onAppear()
        // すぐにローディング状態か確認
        try await Task.sleep(nanoseconds: 50_000_000)
        #expect(state.isFetching)
        // 完了まで待つ
        _ = await task.value
        #expect(!state.isFetching)
    }
}
