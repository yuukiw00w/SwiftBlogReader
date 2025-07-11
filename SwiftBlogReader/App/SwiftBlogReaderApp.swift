import API
import Feature
import SwiftData
import SwiftUI

@main
struct SwiftBlogReaderApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([FeedItem.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration],
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var feedFetcher: any FeedFetcher = DefaultFeedFetcher()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .environment(\.feedFetcher, feedFetcher)
    }
}
