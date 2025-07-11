import Foundation

#if DEBUG
    public struct MockFeedFetcher: FeedFetcher {
        public let mockFetchSwiftOrgFeed: () async throws -> [FeedEntry]
        
        public init(mockFetchSwiftOrgFeed: @escaping () async throws -> [FeedEntry]) {
            self.mockFetchSwiftOrgFeed = mockFetchSwiftOrgFeed
        }

        public func fetchSwiftOrgFeed() async throws -> [FeedEntry] {
            try await mockFetchSwiftOrgFeed()
        }
    }

#endif
