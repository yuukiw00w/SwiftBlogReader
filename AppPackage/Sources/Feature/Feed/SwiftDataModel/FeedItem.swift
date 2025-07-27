public import API
public import Foundation
public import SwiftData

@Model
public final nonisolated class FeedItem: Identifiable, Hashable, Equatable {
    @Attribute(.unique)
    public private(set) var id: String

    public private(set) var title: String
    public private(set) var link: URL
    public private(set) var updatedDate: Date
    public private(set) var author: String?
    public private(set) var content: String?
    public private(set) var contentBaseURL: URL
    public private(set) var isRead: Bool

    public init(
        id: String,
        title: String,
        link: URL,
        updatedDate: Date,
        author: String?,
        content: String?,
        contentBaseURL: URL,
        isRead: Bool = false,
    ) {
        self.id = id
        self.title = title
        self.link = link
        self.updatedDate = updatedDate
        self.author = author
        self.content = content
        self.contentBaseURL = contentBaseURL
        self.isRead = isRead
    }

    public static func placeholder(index: Int) -> FeedItem {
        .init(
            id: "placeholder-\(index)",
            title: "Loading...\(index)",
            link: URL(string: "https://example.com")!,
            updatedDate: Date(),
            author: nil,
            content: nil,
            contentBaseURL: URL(string: "https://example.com")!,
        )
    }

    public func update(from item: FeedItem) {
        title = item.title
        link = item.link
        updatedDate = item.updatedDate
        author = item.author
        content = item.content
    }

    public func update(
        from entry: FeedEntry,
        contentFactory: (String?) -> String?,
    ) {
        title = entry.title
        link = entry.link
        updatedDate = entry.updatedDate
        author = entry.author
        content = contentFactory(entry.htmlContent)
        contentBaseURL = entry.baseURL
    }

    public func markRead() {
        isRead = true
    }
}
