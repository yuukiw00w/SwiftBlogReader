public import Foundation

public nonisolated struct FeedEntity: Identifiable, Hashable, Equatable, Sendable {
    public var id: String

    public var title: String
    public var link: URL
    public var updatedDate: Date
    public var author: String?
    public var content: String?
    public var contentBaseURL: URL
    public var isRead: Bool

    public init(
        id: String,
        title: String,
        link: URL,
        updatedDate: Date,
        author: String?,
        content: String?,
        contentBaseURL: URL,
        isRead: Bool,
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

    public init(from item: FeedItem) {
        id = item.id
        title = item.title
        link = item.link
        updatedDate = item.updatedDate
        author = item.author
        content = item.content
        contentBaseURL = item.contentBaseURL
        isRead = item.isRead
    }

    public static func placeholder(index: Int) -> Self {
        .init(
            id: "placeholder-\(index)",
            title: "Loading...\(index)",
            link: URL(string: "https://example.com")!,
            updatedDate: Date(),
            author: nil,
            content: nil,
            contentBaseURL: URL(string: "https://example.com")!,
            isRead: false,
        )
    }

    public func toItem() -> FeedItem {
        .init(
            id: id,
            title: title,
            link: link,
            updatedDate: updatedDate,
            author: author,
            content: content,
            contentBaseURL: contentBaseURL,
            isRead: isRead,
        )
    }
}
