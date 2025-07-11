import API
import AppIntents
import CoreSpotlight
import Feature
import SwiftData
import SwiftUI

struct ContentView: View {
    @Query private var feed: [FeedItem]

    var body: some View {
        FeedView()
            .onAppear {
                SwiftOrgFeedAppShortcutsProvider.updateAppShortcutParameters()
            }
            .onChange(of: feed) {
                SwiftOrgFeedAppShortcutsProvider.updateAppShortcutParameters()
                if #unavailable(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0) {
                    Task {
                        let searchableIndex = CSSearchableIndex.default()
                        try? await searchableIndex.deleteAppEntities(ofType: FeedIndexedEntity.self)
                        try? await searchableIndex.indexAppEntities(
                            feed.map { FeedIndexedEntity(feedEntity: .init(from: $0)) },
                        )
                    }
                }
            }
    }
}
