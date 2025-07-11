import Foundation

public nonisolated protocol FeedFetcher {
    func fetchSwiftOrgFeed() async throws -> [FeedEntry]
}
