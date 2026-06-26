//
//  MovieViewModelTests.swift
//  SwiftFlixTests
//
//  Created by Kabir Dhillon on 8/25/23.
//

import SwiftData
import XCTest
@testable import SwiftFlix

@MainActor
final class MovieViewModelTests: XCTestCase {
    func test_loadHome_populatesSectionsAndPersistsMovies() async throws {
        let context = try makeContext()
        let client = MockTMDBClient(moviesByCategory: [
            .nowPlaying: [APICallerTests.sampleMovieDTO],
            .popular: [
                APICallerTests.sampleMovieDTO,
                MovieDTO(
                    id: 1,
                    title: "Popular",
                    overview: "",
                    posterPath: nil,
                    backdropPath: nil,
                    voteAverage: 8,
                    releaseDate: nil
                )
            ],
            .upcoming: []
        ])
        let viewModel = MovieViewModel(client: client)

        await viewModel.loadHome(modelContext: context)

        XCTAssertEqual(viewModel.phase, .loaded)
        XCTAssertEqual(viewModel.movies(for: .nowPlaying).map(\.id), [502356])
        XCTAssertEqual(viewModel.movies(for: .popular).map(\.id), [1])
        XCTAssertEqual(context.existingMovie(id: 502356)?.title, "The Super Mario Bros. Movie")
    }

    func test_loadHome_setsErrorState() async throws {
        let context = try makeContext()
        let viewModel = MovieViewModel(client: MockTMDBClient(error: TMDBError.missingAPIKey))

        await viewModel.loadHome(modelContext: context)

        if case .failed(let message) = viewModel.phase {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected failed phase.")
        }
    }

    func test_detailViewModel_togglesBookmarkAndWatched() throws {
        let context = try makeContext()
        let movie = APICallerTests.sampleMovieDTO.makeMovie()
        context.insert(movie)
        let viewModel = MovieDetailViewModel(client: MockTMDBClient())

        viewModel.toggleBookmark(movie: movie, modelContext: context)
        viewModel.toggleWatched(movie: movie, modelContext: context)

        XCTAssertTrue(movie.isBookmarked)
        XCTAssertTrue(movie.isWatched)
    }

    private func makeContext() throws -> ModelContext {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Movie.self,
            Watchlist.self,
            WatchlistCollection.self,
            configurations: configuration
        )
        return ModelContext(container)
    }
}
