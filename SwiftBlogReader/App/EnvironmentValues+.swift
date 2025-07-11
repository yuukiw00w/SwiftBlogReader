import API
import SwiftUI

extension EnvironmentValues {
    @Entry var feedFetcher: any FeedFetcher = DefaultFeedFetcher()
}
