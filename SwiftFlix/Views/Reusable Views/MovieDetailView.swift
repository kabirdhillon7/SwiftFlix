//
//  MovieDetailView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 5/19/23.
//

import CachedAsyncImage
import SwiftData
import SwiftUI
import UIKit

struct MovieDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var colorScheme

    @Bindable var movie: Movie
    @State private var viewModel = MovieDetailViewModel()
    @State private var presentAddToWatchListSheet = false
    @State private var presentRecommendedList = false
    @State private var savedFeedback = false
    @State private var watchedFeedback = false
    @State private var listFeedback = false
    @State private var toastMessage: ToastMessage?

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    hero
                    summary
                    actionCluster
                    overview
                    detailLoadingSkeleton
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
        .toastOverlay(isPresented: toastMessage != nil) {
            if let toastMessage {
                SwiftFlixToast(
                    message: toastMessage.message,
                    systemImage: toastMessage.systemImage,
                    tint: toastMessage.tint
                )
            }
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
                    if let releaseYear = movie.releaseYearText {
                        Text(releaseYear)
                            .foregroundStyle(.secondary)
                    }
                    if let runtime = movie.runtimeText {
                        Text(runtime)
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
                showToast(
                    movie.isBookmarked ? "Saved to your list" : "Removed from saved",
                    systemImage: movie.isBookmarked ? "bookmark.fill" : "bookmark.slash.fill",
                    tint: movie.isBookmarked ? .green : .secondary
                )
            }
            .sensoryFeedback(.success, trigger: savedFeedback)

            detailAction(
                title: "Watched",
                systemImage: movie.isWatched ? "checkmark.circle.fill" : "checkmark.circle",
                isActive: movie.isWatched
            ) {
                viewModel.toggleWatched(movie: movie, modelContext: modelContext)
                watchedFeedback.toggle()
                showToast(
                    movie.isWatched ? "Marked as watched" : "Marked as unwatched",
                    systemImage: movie.isWatched ? "checkmark.circle.fill" : "circle",
                    tint: movie.isWatched ? .green : .secondary
                )
            }
            .sensoryFeedback(.success, trigger: watchedFeedback)

            detailAction(title: "List", systemImage: "plus", isActive: false) {
                listFeedback.toggle()
                presentAddToWatchListSheet = true
            }
            .sensoryFeedback(.selection, trigger: listFeedback)
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(colorScheme == .dark ? Color.white.opacity(0.18) : Color.white.opacity(0.34))
        }
        .liquidGlass(cornerRadius: 28)
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.white.opacity(colorScheme == .dark ? 0.22 : 0.34), lineWidth: 1)
        }
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
            .foregroundStyle(isActive ? .green : actionForeground)
        }
        .buttonStyle(.plain)
    }

    private var actionForeground: Color {
        colorScheme == .dark ? .white.opacity(0.92) : .primary
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
    private var detailLoadingSkeleton: some View {
        if viewModel.phase.isLoading {
            VStack(alignment: .leading, spacing: 18) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(.secondarySystemFill))
                    .frame(width: 110, height: 22)
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(.secondarySystemFill))
                    .aspectRatio(16 / 9, contentMode: .fit)
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(.secondarySystemFill))
                    .frame(width: 150, height: 22)
            }
            .padding(.horizontal)
            .redacted(reason: .placeholder)
        }
    }

    @ViewBuilder
    private var trailerSection: some View {
        if let trailerKey = viewModel.trailerKey {
            detailSection(title: "Trailer") {
                VStack(spacing: 12) {
                    TrailerLinkCard(videoID: trailerKey)

                    HStack(spacing: 12) {
                        Button {
                            openURL(youtubeURL(videoID: trailerKey))
                        } label: {
                            Label("Open", systemImage: "arrow.up.forward.app")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        Button {
                            UIPasteboard.general.url = youtubeURL(videoID: trailerKey)
                            showToast("Trailer link copied", systemImage: "doc.on.doc.fill")
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .controlSize(.regular)
                }
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

    private func youtubeURL(videoID: String) -> URL {
        URL(string: "https://www.youtube.com/watch?v=\(videoID)")!
    }

    private func showToast(
        _ message: String,
        systemImage: String,
        tint: Color = .green
    ) {
        let toast = ToastMessage(message: message, systemImage: systemImage, tint: tint)
        toastMessage = toast

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.6))
            if toastMessage == toast {
                toastMessage = nil
            }
        }
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

private struct ToastMessage: Equatable {
    let id = UUID()
    let message: String
    let systemImage: String
    let tint: Color

    static func == (lhs: ToastMessage, rhs: ToastMessage) -> Bool {
        lhs.id == rhs.id
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
