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
    @State private var viewModel = MovieViewModel()
    @State private var expandedCategory: MovieCategory?

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.phase {
                case .idle:
                    ProgressView("Loading movies")
                        .ralewayFont(.body)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .loading where viewModel.sections.isEmpty:
                    ProgressView("Loading movies")
                        .ralewayFont(.body)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .empty:
                    ContentUnavailableView(
                        "No Movies",
                        systemImage: "film.stack",
                        description: Text("Check your TMDB configuration and try again.")
                    )
                case .failed(let message):
                    ContentUnavailableView(
                        "Could Not Load Movies",
                        systemImage: "wifi.exclamationmark",
                        description: Text(message)
                    )
                default:
                    movieSections
                }
            }
            .navigationTitle("Movies")
            .navigationBarTitleDisplayMode(.inline)
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
}

private struct MovieShelfView: View {
    let title: String
    let movies: [Movie]
    let seeAllAction: () -> Void
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
                Button(action: seeAllAction) {
                    Label("See all", systemImage: "chevron.right")
                        .labelStyle(.iconOnly)
                        .ralewayFont(.footnote)
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.secondary)
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
