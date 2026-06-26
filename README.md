# SwiftFlix

SwiftFlix is a SwiftUI movie discovery app powered by The Movie Database API. It is built as a portfolio-quality iOS app with modern async networking, SwiftData persistence, native search, watchlists, and an iOS 26-first visual refresh inspired by Liquid Glass.

## Highlights

- Browse now playing, popular, and upcoming movies.
- Search TMDB with debounced async/await requests.
- View movie details with artwork, ratings, trailer, cast, recommendations, and watch-provider links.
- Save movies, mark them watched, and organize them into custom watchlists.
- Persist local library state with SwiftData.
- Uses native SwiftUI structures like `TabView`, `NavigationStack`, `List`, `searchable`, and iOS 26 Liquid Glass effects with fallbacks.

## Requirements

- Xcode 26 or newer
- iOS 17.0 minimum deployment target
- iOS 26 simulator/device recommended for Liquid Glass
- TMDB API key

## Setup

1. Create a TMDB API key from [The Movie Database](https://www.themoviedb.org/).
2. Copy `Config/Secrets.xcconfig.sample` to `Config/Secrets.xcconfig`.
3. Replace `your_tmdb_api_key_here` with your API key.
4. Build or run the app. `Config/SwiftFlix.xcconfig` is already wired into the app target and optionally loads your local secrets file.

`Config/Secrets.xcconfig` is ignored by Git so the API key stays out of source control. The app reads the value through the `TMDBAPIKey` Info.plist entry.

## Architecture

SwiftFlix uses a small MVVM structure:

- `TMDBClientProtocol` defines async TMDB operations.
- `TMDBClient` builds requests, validates HTTP responses, and decodes DTOs.
- Remote DTOs such as `MovieDTO`, `Credits`, and `WatchProviderResults` are plain `Decodable` structs.
- SwiftData models are reserved for local persistence, primarily `Movie` and `Watchlist`.
- View models are `@MainActor @Observable` types with explicit loading, empty, loaded, and failed states.

The app intentionally avoids Combine in networking and view models. Search uses task cancellation plus a short debounce delay to keep the UI responsive without flooding the API.

## Verification

Useful commands:

```sh
xcodebuild -project SwiftFlix.xcodeproj -scheme MovieFlix -destination 'generic/platform=iOS' build CODE_SIGNING_ALLOWED=NO
xcodebuild -project SwiftFlix.xcodeproj -scheme MovieFlix -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test CODE_SIGNING_ALLOWED=NO
```

## Dependencies

- SwiftUI
- SwiftData
- WebKit
- [swiftui-cached-async-image](https://github.com/lorenzofiamingo/swiftui-cached-async-image)

## Contact

- GitHub: [@kabirdhillon7](https://github.com/kabirdhillon7)
- LinkedIn: [Kabir Dhillon](https://www.linkedin.com/in/kabirdhillon/)
