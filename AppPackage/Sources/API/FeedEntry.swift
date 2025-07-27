public import Foundation

public struct FeedEntry: Equatable, Identifiable, Hashable {
    public let id: String
    public var title: String
    public var link: URL
    public var updatedDate: Date
    public var baseURL: URL
    public var author: String?
    public var htmlContent: String?

    public init(id: String, title: String, link: URL, updatedDate: Date, baseURL: URL, author: String? = nil, htmlContent: String? = nil) {
        self.id = id
        self.title = title
        self.link = link
        self.updatedDate = updatedDate
        self.author = author
        self.htmlContent = htmlContent
        self.baseURL = baseURL
    }
}
