import Feature
import SwiftUI

struct FeedContentView: View {
    let eventAcceptor: FeedViewEventAcceptor
    @Binding var state: FeedViewState

    var body: some View {
        FeedListView(
            selection: .init(
                get: { state.selected },
                set: { eventAcceptor.onItemSelected($0) },
            ),
            feed: state.filteredFeed,
        )
        .onAppear {
            eventAcceptor.onAppear()
        }
        .redacted(reason: state.shouldShowPlaceholder ? .placeholder : [])
        .refreshable {
            await eventAcceptor.onRefresh()
        }
        .toolbar {
            ToolbarItem {
                Button(
                    action: { Task { await eventAcceptor.onRefresh() } },
                    label: {
                        if state.isFetching {
                            ProgressView()
                        } else {
                            Label(.refresh, systemImage: "arrow.clockwise")
                        }
                    },
                )
                .disabled(state.isFetching)
            }
        }
        .searchable(
            text: .init(
                get: {
                    state.searchText
                },
                set: { state.update(by: .onSetSearchText($0)) },
            ),
        )
    }
}
