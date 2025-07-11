import AppIntents

nonisolated struct SwiftOrgFeedAppShortcutsProvider: AppShortcutsProvider {
    @AppShortcutsBuilder static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: FetchSwiftOrgFeedAppIntent(),
            phrases: [
                "Fetch Swift.org Blog Feed for \(.applicationName)",
            ],
            shortTitle: "Fetch Swift.org Blog Feed",
            systemImageName: "swift",
        )
    }

    static var shortcutTileColor: ShortcutTileColor { .orange }
}
