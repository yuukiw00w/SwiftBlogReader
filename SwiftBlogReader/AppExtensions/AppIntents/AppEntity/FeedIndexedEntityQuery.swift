import API
import AppIntents
import Feature
import SwiftData

struct FeedIndexedEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) throws -> [FeedIndexedEntity] {
        let schema = Schema([FeedItem.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
        )

        let container = try ModelContainer(
            for: schema,
            configurations: [modelConfiguration],
        )

        let feed = try container.mainContext.fetch(
            FetchDescriptor<FeedItem>(
                predicate: #Predicate { identifiers.contains($0.id) }
            ),
        )

        return feed.map { .init(feedEntity: FeedEntity(from: $0)) }
    }

    func suggestedEntities() throws -> [FeedIndexedEntity] {
        let schema = Schema([FeedItem.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
        )

        let container = try ModelContainer(
            for: schema,
            configurations: [modelConfiguration],
        )

        let feed = try container.mainContext.fetch(
            FetchDescriptor<FeedItem>(),
        )

        return feed.map { .init(feedEntity: FeedEntity(from: $0)) }
    }
}
