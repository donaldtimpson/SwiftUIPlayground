# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

**Build:**
```bash
xcodebuild build -scheme SwiftUIPlayground -destination 'platform=macOS'
```

**Test (unit):**
```bash
xcodebuild test -scheme SwiftUIPlayground -destination 'platform=macOS' -only-testing:SwiftUIPlaygroundTests
```

**Test (UI):**
```bash
xcodebuild test -scheme SwiftUIPlayground -destination 'platform=macOS' -only-testing:SwiftUIPlaygroundUITests
```

No linting tools (e.g., SwiftLint) are currently configured.

## Architecture

This is a SwiftUI + SwiftData iOS/macOS app — a simple to-do/notes manager with no third-party dependencies.

**Entry point:** `SwiftUIPlaygroundApp.swift` sets up the `ModelContainer` with the `Item` schema and injects it into the view hierarchy via `.modelContainer()`.

**Data model:** `Item.swift` is a SwiftData `@Model` with `timestamp: Date`, `text: String`, and `type: ItemType` (enum with `.todo` and `.note` cases). Data is persisted to local device storage.

**Main UI:** `ContentView.swift` uses a `NavigationSplitView` (sidebar + detail). The sidebar lists items via `@Query`, with toolbar buttons for adding/deleting. Model access goes through `@Environment(\.modelContext)`.

**Known issue:** `ContentView` calls `Item(timestamp: Date())` but `Item`'s initializer requires all three parameters — this causes a compile error. Fix by either adding default values to the initializer or updating the call site in `ContentView`.
