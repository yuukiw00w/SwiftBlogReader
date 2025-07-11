import Feature
import SwiftUI

struct FeedListView: View {
    @Binding var selection: FeedEntity?
    let feed: [FeedEntity]

    var body: some View {
        if feed.isEmpty {
            ContentUnavailableView(.notFoundFeed, systemImage: "xmark")
        } else {
            List(feed, id: \.self, selection: $selection) { article in
                Text(article.title)
                    .foregroundStyle(article.isRead ? .secondary : .primary)
            }
        }
    }
}
