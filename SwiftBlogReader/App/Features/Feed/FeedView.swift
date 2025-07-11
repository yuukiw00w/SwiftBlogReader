import API
import Feature
import SwiftData
import SwiftUI

struct FeedView: View {
    @Environment(\.modelContext)
    private var modelContext

    @Environment(\.feedFetcher)
    private var feedFetcher

    private var eventAcceptor: FeedViewEventAcceptor {
        .init(
            repository: .init(
                modelContext: modelContext,
                feedFetcher: feedFetcher,
            ),
        ) { event in
            state.update(by: event)
        }
    }

    @State private var state: FeedViewState = .init()

    var body: some View {
        if #available(iOS 26.0, *) {
            NavigationSplitView {
                FeedContentView(eventAcceptor: eventAcceptor, state: $state)
            } detail: {
                FeedDetailView(selected: state.selected)
            }
            .navigationTitle(title)
            .navigationSubtitle(subtitle)
        } else {
            NavigationSplitView {
                FeedContentView(eventAcceptor: eventAcceptor, state: $state)
            } detail: {
                FeedDetailView(selected: state.selected)
            }
            .navigationTitle(title)
        }
    }

    private var title: String {
        if let selectedItem = state.selected {
            selectedItem.title
        } else {
            String(localized: .swiftBlogReader)
        }
    }

    private var subtitle: String {
        if state.selected != nil {
            ""
        } else {
            state.fetchStatus.localizedMessage
        }
    }
}

extension FetchFeedStatus {
    var localizedMessage: String {
        switch self {
        case .idle:
            String(localized: .notFetched)

        case .fetching:
            String(localized: .fetching)

        case let .fetched(date):
            date.formatted()

        case let .failed(error):
            error.localizedDescription
        }
    }
}

#Preview {
    FeedView()
        .modelContainer(
            for: FeedItem.self,
            inMemory: true,
            onSetup: { result in
                if case let .success(container) = result {
                    container.mainContext.insert(
                        FeedItem(
                            id: UUID().uuidString,
                            title: "Test",
                            link: URL(string: "https://www.google.com")!,
                            updatedDate: .now,
                            author: "Preview Author",
                            content: "<p>This is a test post.</p>",
                            contentBaseURL: URL(
                                string: "https://www.google.com",
                            )!,
                        ),
                    )
                }
            },
        )
        .environment(
            \.feedFetcher,
            MockFeedFetcher(mockFetchSwiftOrgFeed: {
                [
                    .init(
                        id: "1",
                        title: "title",
                        link: URL(string: "https://www.google.com")!,
                        updatedDate: .now,
                        baseURL: URL(string: "https://www.google.com")!,
                    ),
                ]
            }),
        )
}
