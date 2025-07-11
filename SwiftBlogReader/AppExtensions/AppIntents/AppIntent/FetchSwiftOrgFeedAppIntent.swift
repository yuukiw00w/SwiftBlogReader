import AppIntents
import Feature
import SwiftData

nonisolated struct FetchSwiftOrgFeedAppIntent: AppIntent {
    static var title: LocalizedStringResource { "fetch_swift_org_blog_app_intent_title" }

    @MainActor
    func perform() throws -> some IntentResult & ReturnsValue<[FeedIndexedEntity]> {
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

        return .result(value: feed.map { FeedIndexedEntity(feedEntity: .init(from: $0)) })
    }
}
