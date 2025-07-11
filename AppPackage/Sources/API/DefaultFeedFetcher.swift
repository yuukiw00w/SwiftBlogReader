import FeedKit
import Foundation
internal import XMLKit

private var swiftOrgBaseURLString: String { "https://www.swift.org/" }
private var swiftOrgBaseURL: URL { URL(string: swiftOrgBaseURLString)! }
private var swiftOrgFeedURLString: String { "\(swiftOrgBaseURLString)atom.xml" }

public struct DefaultFeedFetcher: FeedFetcher {
    public init() {}

    public func fetchSwiftOrgFeed() async throws -> [FeedEntry] {
        let atomFeed = try await AtomFeed(urlString: swiftOrgFeedURLString)
        return (atomFeed.entries ?? []).compactMap { entry in
            guard
                let id = entry.id,
                let title = entry.title,
                let linksFirstHref = entry.links?.first?.attributes?.href,
                let link = URL(string: linksFirstHref),
                let updatedDate = entry.updated
            else {
                return nil
            }
            let author = entry.authors?.first?.name
            let content = entry.content?.text
            return FeedEntry(
                id: id,
                title: title,
                link: link,
                updatedDate: updatedDate,
                baseURL: swiftOrgBaseURL,
                author: author,
                htmlContent: content,
            )
        }
    }
}
