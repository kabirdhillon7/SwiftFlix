//
//  MovieDetailView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 5/19/23.
//

import CachedAsyncImage
import SwiftData
import SwiftUI

struct MovieDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @Bindable var movie: Movie
    @State private var viewModel = MovieDetailViewModel()
    @State private var presentAddToWatchListSheet = false
    @State private var presentRecommendedList = false
    @State private var savedFeedback = false
    @State private var watchedFeedback = false

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    hero
                    summary
                    actionCluster
                    overview
                    trailerSection
                    watchSection
                    creditsSection
                    recommendedSection
                }
                .frame(width: proxy.size.width, alignment: .leading)
                .padding(.bottom, 32)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load(movie: movie, modelContext: modelContext)
        }
        .navigationDestination(isPresented: $presentRecommendedList) {
            ExpandedMovieGridView(title: "Recommended", movies: viewModel.recommendedMovies)
        }
        .sheet(isPresented: $presentAddToWatchListSheet) {
            NavigationStack {
                AddToWatchListView(movie: movie)
            }
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            if let backdropPath = movie.backdropPath, !backdropPath.isEmpty {
                CachedAsyncImage(url: TMDBImage.backdrop(path: backdropPath, width: .w1280)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        heroPlaceholder
                    default:
                        ZStack {
                            heroPlaceholder
                            ProgressView()
                        }
                    }
                }
            } else {
                heroPlaceholder
            }
        }
        .frame(height: 310)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .overlay(
            LinearGradient(
                colors: [.clear, Color(.systemBackground).opacity(0.25), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipped()
    }

    private var heroPlaceholder: some View {
        ZStack {
            Rectangle()
                .fill(Color(.secondarySystemBackground))
            Image(systemName: "film")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
        }
    }

    private var summary: some View {
        HStack(alignment: .top, spacing: 16) {
            PosterImage(path: movie.posterPath, width: 124)
                .padding(.top, -76)

            VStack(alignment: .leading, spacing: 10) {
                Text(movie.title)
                    .ralewayFont(.largeTitle, size: 28)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    Label(String(format: "%.1f", movie.voteAverage), systemImage: "star.fill")
                        .foregroundStyle(.orange)
                    if let releaseDate = movie.releaseDate, !releaseDate.isEmpty {
                        Text(releaseDate.prefix(4))
                            .foregroundStyle(.secondary)
                    }
                }
                .ralewayFont(.body, weight: .medium)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionCluster: some View {
        HStack(spacing: 14) {
            detailAction(
                title: "Saved",
                systemImage: movie.isBookmarked ? "bookmark.fill" : "bookmark",
                isActive: movie.isBookmarked
            ) {
                viewModel.toggleBookmark(movie: movie, modelContext: modelContext)
                savedFeedback.toggle()
            }
            .sensoryFeedback(.success, trigger: savedFeedback)

            detailAction(
                title: "Watched",
                systemImage: movie.isWatched ? "checkmark.circle.fill" : "checkmark.circle",
                isActive: movie.isWatched
            ) {
                viewModel.toggleWatched(movie: movie, modelContext: modelContext)
                watchedFeedback.toggle()
            }
            .sensoryFeedback(.success, trigger: watchedFeedback)

            detailAction(title: "List", systemImage: "plus", isActive: false) {
                presentAddToWatchListSheet = true
            }
        }
        .padding(10)
        .liquidGlass(cornerRadius: 28)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }

    private func detailAction(
        title: String,
        systemImage: String,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .contentTransition(.symbolEffect(.replace))
                Text(title)
                    .ralewayFont(.caption, weight: .medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .foregroundStyle(isActive ? .green : .primary)
        }
        .buttonStyle(.plain)
    }

    private var overview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Overview")
                .ralewayFont(.title)
            Text(movie.overview.isEmpty ? "No overview available." : movie.overview)
                .ralewayFont(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var trailerSection: some View {
        if let trailerKey = viewModel.trailerKey {
            detailSection(title: "Trailer") {
                TrailerLinkCard(videoID: trailerKey)
            }
        }
    }

    @ViewBuilder
    private var watchSection: some View {
        if let watchProviderLink = viewModel.watchProviderLink {
            detailSection(title: "Watch") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Streaming information provided by JustWatch.")
                        .ralewayFont(.caption)
                        .foregroundStyle(.secondary)

                    Button {
                        openURL(watchProviderLink)
                    } label: {
                        Label("View Watch Providers", systemImage: "play.tv")
                            .ralewayFont(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
        }
    }

    @ViewBuilder
    private var creditsSection: some View {
        if let credits = viewModel.credits, !credits.cast.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Cast & Crew")
                    .ralewayFont(.title)
                    .padding(.horizontal)

                ScrollView(.horizontal) {
                    LazyHStack(spacing: 16) {
                        ForEach(credits.cast.prefix(12)) { cast in
                            CastCard(cast: cast)
                        }
                    }
                    .scrollTargetLayout()
                }
                .contentMargins(.horizontal, 16, for: .scrollContent)
                .scrollIndicators(.hidden)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var recommendedSection: some View {
        if !viewModel.recommendedMovies.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Recommended")
                        .ralewayFont(.title)
                    Spacer()
                    Button {
                        presentRecommendedList = true
                    } label: {
                        Label("See all", systemImage: "chevron.right")
                            .ralewayFont(.footnote)
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                ScrollView(.horizontal) {
                    LazyHStack(spacing: 14) {
                        ForEach(viewModel.recommendedMovies) { movie in
                            NavigationLink {
                                MovieDetailView(movie: movie)
                            } label: {
                                PosterImage(path: movie.posterPath, width: 132)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .scrollTargetLayout()
                }
                .contentMargins(.horizontal, 16, for: .scrollContent)
                .scrollTargetBehavior(.viewAligned)
                .scrollIndicators(.hidden)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func detailSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .ralewayFont(.title)
            content()
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct TrailerLinkCard: View {
    let videoID: String

    private var youtubeURL: URL {
        URL(string: "https://www.youtube.com/watch?v=\(videoID)")!
    }

    private var thumbnailURL: URL? {
        URL(string: "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg")
    }

    var body: some View {
        Link(destination: youtubeURL) {
            ZStack {
                CachedAsyncImage(url: thumbnailURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        trailerPlaceholder
                    }
                }

                LinearGradient(
                    colors: [.black.opacity(0.55), .black.opacity(0.08)],
                    startPoint: .bottom,
                    endPoint: .top
                )

                VStack(spacing: 10) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 58, height: 58)
                        .background(.black.opacity(0.38), in: Circle())
                        .liquidGlassCircle()

                    Text("Watch Trailer")
                        .ralewayFont(.headline)
                        .foregroundStyle(.white)
                }
            }
            .aspectRatio(16 / 9, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.16), radius: 14, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Watch trailer on YouTube")
    }

    private var trailerPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.secondarySystemBackground))

            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
        }
    }
}

private struct CastCard: View {
    let cast: Cast
    private let cardWidth: CGFloat = 136
    private var portraitHeight: CGFloat { cardWidth * 1.18 }

    var body: some View {
        VStack(spacing: 4) {
            portrait

            Text(cast.name)
                .ralewayFont(.caption, weight: .semibold)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity)
                .frame(height: 34, alignment: .top)

            Text(cast.character)
                .ralewayFont(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity)
                .frame(height: 34, alignment: .top)
        }
        .frame(width: cardWidth, alignment: .top)
    }

    @ViewBuilder
    private var portrait: some View {
        if let profilePath = cast.profilePath, !profilePath.isEmpty {
            CachedAsyncImage(url: TMDBImage.poster(path: profilePath, width: .w185)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    personPlaceholder
                }
            }
            .frame(width: cardWidth, height: portraitHeight)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        } else {
            personPlaceholder
        }
    }

    private var personPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.tertiarySystemFill),
                            Color(.secondarySystemBackground)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            if let initials {
                Text(initials)
                    .ralewayFont(.title, size: 28, weight: .bold)
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "person.crop.rectangle.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: cardWidth, height: portraitHeight)
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        }
    }

    private var initials: String? {
        let parts = cast.name
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)

        guard !parts.isEmpty else { return nil }
        return String(parts).uppercased()
    }
}

#Preview {
    NavigationStack {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Movie.self, configurations: config)
            let sampleMovie = Movie(
                id: 502356,
                title: "The Super Mario Bros. Movie",
                overview: "While working underground to fix a water main, Brooklyn plumbers Mario and Luigi are transported down a mysterious pipe and wander into a magical new world.",
                posterPath: "/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg",
                backdropPath: "/nLBRD7UPR6GjmWQp6ASAfCTaWKX.jpg",
                voteAverage: 7.7,
                isWatched: false,
                isBookmarked: false
            )

            return MovieDetailView(movie: sampleMovie)
                .modelContainer(container)
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }
}
