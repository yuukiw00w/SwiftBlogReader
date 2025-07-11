import Feature
import SwiftUI
import WebKit

struct FeedDetailView: View {
    let selected: FeedEntity?

    var body: some View {
        if let selected {
            if let content = selected.content {
                BlogContentView(
                    html: content,
                    baseURL: selected.contentBaseURL,
                )
            } else {
                WebView(url: selected.link)
            }
        } else {
            Text(.noSelectedFeedItem)
        }
    }
}
