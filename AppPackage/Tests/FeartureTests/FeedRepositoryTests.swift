import Foundation
import SwiftData
import Testing

@testable import API
@testable import Feature

@MainActor
struct FeedRepositoryTests {
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
            htmlContent: htmlContent ?? "html" + id
        )
    }

    private func makeFeedItem(
        id: String = "1",
        title: String? = nil,
        link: String? = nil,
        updatedDate: Date = Date(timeIntervalSince1970: 0),
        author: String? = nil,
        content: String? = nil,
    ) -> FeedItem {
        FeedItem(
            id: id,
            title: title ?? "title" + id,
            link: link == nil
                ? URL(string: "https://example.com/" + id)!
                : URL(string: link!)!,
            updatedDate: updatedDate,
            author: author,
            content: content ?? "html" + id,
            contentBaseURL: URL(string: "https://example.com/")!
        )
    }

    @Test func fetchFeed_キャッシュなし新規1件取得() async throws {
        let container = try makeInMemoryModelContainer()
        let context = container.mainContext
        let entry = makeFeedEntry()
        let repo = feedRepository(context, [entry])
        let result = try await repo.fetchNonCachedFeed(cached: [])
        #expect(result.count == 1, "新規アイテムが1件返ること")
        #expect(result[0].id == "1", "返されたIDが'1'であること")
        #expect(
            result[0].content?.contains("<html>") == true,
            "contentがHTMLラップされていること"
        )
        #expect(
            result[0].content?.contains("html") == true,
            "contentに元のhtml文字列が含まれていること"
        )

        let cached = try context.fetch(FetchDescriptor<FeedItem>())
        #expect(cached.count == 1, "DBにも1件保存されていること")
        #expect(cached[0].id == "1", "保存されたIDが'1'であること")
    }

    @Test func fetchFeed_キャッシュ1件が更新される() async throws {
        let container = try makeInMemoryModelContainer()
        let context = container.mainContext
        // 既存キャッシュ
        let cachedItem = makeFeedItem(id: "1")
        context.insert(cachedItem)
        let entity = FeedEntity(from: cachedItem)
        try context.save()
        // 新しいフィード（同じID, 内容が異なる）
        let entry = makeFeedEntry(
            id: "1",
            title: "new title",
            updatedDate: Date(timeIntervalSince1970: 1),
            author: "new author",
            htmlContent: "new html",
        )
        let repo = feedRepository(context, [entry])
        let result = try await repo.fetchNonCachedFeed(cached: [entity])
        #expect(result.isEmpty, "既存アイテムが更新され、新規追加はないこと")
        let cached = try context.fetch(FetchDescriptor<FeedItem>())
        #expect(cached.count == 1, "DBには1件のみ存在")
        #expect(cached[0].title == entry.title, "タイトルが新しい値で上書きされていること")
        #expect(cached[0].author == entry.author, "著者が新しい値で上書きされていること")
        #expect(
            cached[0].content?.contains("new html") == true,
            "contentが新しい値で上書きされていること"
        )
    }

    @Test func fetchFeed_キャッシュと同じものを取得() async throws {
        let container = try makeInMemoryModelContainer()
        let context = container.mainContext
        let cachedItem = makeFeedItem()
        context.insert(cachedItem)
        let entity = FeedEntity(from: cachedItem)
        try context.save()
        let entry = makeFeedEntry()
        let repo = feedRepository(context, [entry])
        let result = try await repo.fetchNonCachedFeed(cached: [entity])
        #expect(result.isEmpty, "既存と同じ内容の場合は新規追加されないこと")
        let cached = try context.fetch(FetchDescriptor<FeedItem>())
        #expect(cached.count == 1, "DBには1件のみ存在")
    }

    @Test func fetchFeed_取得したものがupdatedDate降順になること() async throws {
        let container = try makeInMemoryModelContainer()
        let context = container.mainContext
        // 固定日時で3件用意
        let date1 = Date(timeIntervalSince1970: 3000)  // newest
        let date2 = Date(timeIntervalSince1970: 2000)
        let date3 = Date(timeIntervalSince1970: 1000)  // oldest
        let entry1 = makeFeedEntry(id: "1", updatedDate: date1)
        let entry2 = makeFeedEntry(id: "2", updatedDate: date2)
        let entry3 = makeFeedEntry(id: "3", updatedDate: date3)
        let repo = feedRepository(context, [entry1, entry2, entry3])
        _ = try await repo.fetchNonCachedFeed(cached: [])
        let cached = try repo.fetchCacheItems()
        #expect(cached.count == 3, "キャッシュ件数が期待通りであること")
        #expect(cached[0].id == "1", "updatedDateが最も新しいものが先頭")
        #expect(cached[1].id == "2", "2番目に新しいもの")
        #expect(cached[2].id == "3", "updatedDateが最も古いものが末尾")
    }

    @Test func fetchFeed_APIエラー() async throws {
        let container = try makeInMemoryModelContainer()
        let context = container.mainContext
        let mockError = NSError(domain: "TestError", code: 123)
        let repo = FeedRepository(
            modelContext: context,
            feedFetcher: MockFeedFetcher(
                mockFetchSwiftOrgFeed: { throw mockError }
            )
        )
        await #expect(throws: (any Error).self, performing: {
            try await repo.fetchNonCachedFeed(cached: [])
        })
    }
}
