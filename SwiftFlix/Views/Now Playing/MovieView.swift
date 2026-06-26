//
//  ContentView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import SwiftData
import SwiftUI

struct MovieView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Movie.title) private var persistedMovies: [Movie]

    @State private var viewModel = MovieViewModel()
    @State private var expandedCategory: MovieCategory?

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.phase {
                case .idle:
                    HomeSkeletonView()
                case .loading where viewModel.sections.isEmpty:
                    HomeSkeletonView()
                case .empty:
                    emptyState
                case .failed(let message):
                    errorState(message)
                default:
                    movieSections
                }
            }
            .navigationTitle("Movies")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $expandedCategory) { category in
                ExpandedMovieGridView(
                    title: category.title,
                    movies: viewModel.movies(for: category)
                )
                .padding(.horizontal)
            }
            .refreshable {
                await viewModel.loadHome(modelContext: modelContext)
            }
            .task {
                await viewModel.loadHome(modelContext: modelContext)
            }
        }
    }

    private var movieSections: some View {
        ScrollView {
            LazyVStack(spacing: 28) {
                let recentMovies = Array(persistedMovies.recentlyViewed.prefix(10))
                if !recentMovies.isEmpty {
                    MovieShelfView(
                        title: "Recently Viewed",
                        movies: recentMovies,
                        seeAllAction: nil
                    )
                }

                ForEach(MovieCategory.allCases) { category in
                    let movies = viewModel.movies(for: category)
                    if !movies.isEmpty {
                        MovieShelfView(
                            title: category.title,
                            movies: movies,
                            seeAllAction: {
                                expandedCategory = category
                            }
                        )
                    }
                }
            }
            .padding(.top, 26)
            .padding(.bottom, 16)
        }
        .scrollIndicators(.hidden)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            ContentUnavailableView(
                "No Movies",
                systemImage: "film.stack",
                description: Text("Check your TMDB configuration and try again.")
            )

            Button {
                Task {
                    await viewModel.loadHome(modelContext: modelContext)
                }
            } label: {
                Label("Retry", systemImage: "arrow.clockwise")
            }
            .buttonStyle(TintedGlassButtonStyle(tint: .accentColor))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 16) {
            ContentUnavailableView(
                "Could Not Load Movies",
                systemImage: "wifi.exclamationmark",
                description: Text(message)
            )

            Button {
                Task {
                    await viewModel.loadHome(modelContext: modelContext)
                }
            } label: {
                Label("Try Again", systemImage: "arrow.clockwise")
            }
            .buttonStyle(TintedGlassButtonStyle(tint: .accentColor))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct MovieShelfView: View {
    let title: String
    let movies: [Movie]
    let seeAllAction: (() -> Void)?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var cardWidth: CGFloat {
        horizontalSizeClass == .compact ? 300 : 340
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .ralewayFont(.title)
                Spacer()
                if let seeAllAction {
                    Button(action: seeAllAction) {
                        Label("See all", systemImage: "chevron.right")
                            .labelStyle(.iconOnly)
                            .ralewayFont(.footnote)
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)

            ScrollView(.horizontal) {
                LazyHStack(spacing: 14) {
                    ForEach(movies) { movie in
                        NavigationLink {
                            MovieDetailView(movie: movie)
                        } label: {
                            MovieCardView(movie: movie)
                                .frame(width: cardWidth)
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
    }
}

private struct HomeSkeletonView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 28) {
                ForEach(0..<3, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 12) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color(.secondarySystemFill))
                            .frame(width: index == 0 ? 150 : 120, height: 24)
                            .padding(.horizontal)

                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 14) {
                                ForEach(0..<3, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color(.secondarySystemFill))
                                        .frame(width: 300)
                                        .aspectRatio(16 / 9, contentMode: .fit)
                                }
                            }
                        }
                        .contentMargins(.horizontal, 16, for: .scrollContent)
                        .scrollIndicators(.hidden)
                    }
                }
            }
            .padding(.top, 26)
        }
        .redacted(reason: .placeholder)
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Movie.self, configurations: config)
        return MovieView()
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
    }
}
