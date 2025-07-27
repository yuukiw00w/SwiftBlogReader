public import API
import FeedKit
public import Foundation
public import SwiftData
internal import XMLKit

public enum FeedRepositoryError: Error {
    /// ネットワークやAPIなど、リモートからのデータ取得に関するエラー
    case networkError(any Error)
    /// ローカルデータベースなど、永続化ストレージへのアクセスに関するエラー
    case storageError(any Error)
}

public final class FeedRepository {
    private let modelContext: ModelContext
    private let feedFetcher: any FeedFetcher
    private let htmlWrapper: HTMLAutoDarkModeWrapper

    public init(
        modelContext: ModelContext,
        feedFetcher: any FeedFetcher = DefaultFeedFetcher(),
        htmlWrapper: HTMLAutoDarkModeWrapper = HTMLAutoDarkModeWrapper(),
    ) {
        self.modelContext = modelContext
        self.htmlWrapper = htmlWrapper
        self.feedFetcher = feedFetcher
    }

    @discardableResult
    public func fetchNonCachedFeed(
        cached: [FeedEntity],
        order: (FeedEntity, FeedEntity) -> Bool = {
            $0.updatedDate > $1.updatedDate
        },
    ) async throws(FeedRepositoryError) -> [FeedEntity] {
        let entries: [FeedEntry]
        do {
            entries = try await feedFetcher.fetchSwiftOrgFeed()
        } catch {
            throw .networkError(error)
        }
        var appendFeed: [FeedEntity] = []
        for entry in entries {
            let cachedItem = cached.first(where: { $0.id == entry.id })
            let item = FeedItem(
                id: entry.id,
                title: entry.title,
                link: entry.link,
                updatedDate: entry.updatedDate,
                author: entry.author,
                content: htmlWrapper(entry.htmlContent),
                contentBaseURL: entry.baseURL,
                isRead: cachedItem?.isRead ?? false,
            )
            if cachedItem == nil {
                appendFeed.append(.init(from: item))
            }
            modelContext.insert(item)
        }
        do {
            try modelContext.save()
        } catch {
            throw .storageError(error)
        }
        return appendFeed.sorted(by: order)
    }

    public func fetchCacheItems() throws -> [FeedEntity] {
        do {
            let feed = try modelContext.fetch(
                FetchDescriptor<FeedItem>(
                    sortBy: [.init(\.updatedDate, order: .reverse)],
                ),
            )
            return feed.map { .init(from: $0) }
        } catch {
            throw FeedRepositoryError.storageError(error)
        }
    }

    public func markRead(entity: FeedEntity) throws(FeedRepositoryError) {
        let id = entity.id
        let predicate = #Predicate<FeedItem> { $0.id == id }
        var fetchDescriptor = FetchDescriptor<FeedItem>(
            predicate: predicate,
        )
        fetchDescriptor.fetchLimit = 1
        do {
            let cachedItem = try modelContext.fetch(fetchDescriptor).first
            cachedItem?.markRead()
            try modelContext.save()
        } catch {
            throw .storageError(error)
        }
    }
}

// 暫定対応：KeyPath が Sendable でないことによる警告を抑制する
// Root や Value が Sendable でも、KeyPath に含まれる subscript の引数が Sendable である保証がないため、
// 自動的に Sendable にはならず、 @unchecked Sendable で暫定的に回避している
extension KeyPath: @unchecked @retroactive Sendable
    where Root: Sendable, Value: Sendable {}
