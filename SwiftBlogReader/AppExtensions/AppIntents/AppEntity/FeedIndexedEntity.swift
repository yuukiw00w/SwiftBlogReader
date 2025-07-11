import AppIntents
import CoreSpotlight
import Feature

nonisolated struct FeedIndexedEntity: IndexedEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "article", numericFormat: "article_numerics")
    }

    static var defaultQuery: FeedIndexedEntityQuery {
        FeedIndexedEntityQuery()
    }

    var displayRepresentation: DisplayRepresentation {
        if #available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, *) {
            .init(title: "\(title)", subtitle: "\(authorNames.joined(separator: ","))")
        } else {
            .init(title: "\(feedEntity.title)", subtitle: "\(feedEntity.author ?? "")")
        }
    }

    var feedEntity: FeedEntity

    var id: String { feedEntity.id }

    @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, *)
    @ComputedProperty(indexingKey: \.title)
    var title: String { feedEntity.title }

    @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, *)
    @ComputedProperty(indexingKey: \.downloadedDate)
    var downloadedDate: Date { feedEntity.updatedDate }

    @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, *)
    @ComputedProperty(indexingKey: \.contentURL)
    var contentURL: URL { feedEntity.link }

    @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, *)
    @ComputedProperty(indexingKey: \.authorNames)
    var authorNames: [String] {
        if let author = feedEntity.author {
            [author]
        } else {
            []
        }
    }

    var attributeSet: CSSearchableItemAttributeSet {
        let attributes = CSSearchableItemAttributeSet(itemContentType: UTType.content.identifier)

        attributes.title = feedEntity.title
        attributes.downloadedDate = feedEntity.updatedDate
        attributes.contentURL = feedEntity.link
        let authorNames: [String] = if let author = feedEntity.author { [author] } else { [] }
        attributes.authorNames = authorNames
        attributes.keywords = [feedEntity.title] + authorNames

        return attributes
    }

    init(feedEntity: FeedEntity) {
        self.feedEntity = feedEntity
    }
}
