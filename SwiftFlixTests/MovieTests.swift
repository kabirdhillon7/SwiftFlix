//
//  MovieTests.swift
//  SwiftFlixTests
//
//  Created by Kabir Dhillon on 9/18/23.
//

import XCTest
import SwiftData
@testable import SwiftFlix

final class MovieTests: XCTestCase {
    func test_movieDTO_decodesFromTMDBPayload() throws {
        let data = """
        {
          "id": 502356,
          "title": "The Super Mario Bros. Movie",
          "overview": "A colorful adventure.",
          "poster_path": "/poster.jpg",
          "backdrop_path": "/backdrop.jpg",
          "vote_average": 7.7,
          "release_date": "2023-04-05"
        }
        """.data(using: .utf8)!

        let movie = try JSONDecoder().decode(MovieDTO.self, from: data)

        XCTAssertEqual(movie.id, 502356)
        XCTAssertEqual(movie.posterPath, "/poster.jpg")
        XCTAssertEqual(movie.backdropPath, "/backdrop.jpg")
        XCTAssertEqual(movie.voteAverage, 7.7)
        XCTAssertEqual(movie.releaseDate, "2023-04-05")
    }

    func test_movieDTO_makesPersistedMovieDefaults() {
        let movie = APICallerTests.sampleMovieDTO.makeMovie()

        XCTAssertEqual(movie.id, 502356)
        XCTAssertEqual(movie.title, "The Super Mario Bros. Movie")
        XCTAssertFalse(movie.isWatched)
        XCTAssertFalse(movie.isBookmarked)
    }

    func test_movie_equalityUsesID() {
        let first = APICallerTests.sampleMovieDTO.makeMovie()
        let second = Movie(
            id: first.id,
            title: "Different title",
            overview: "",
            posterPath: nil,
            backdropPath: nil,
            voteAverage: 0,
            isWatched: true,
            isBookmarked: true
        )

        XCTAssertEqual(first, second)
    }

    func test_watchlist_toggleAddsAndRemovesMovie() {
        let movie = APICallerTests.sampleMovieDTO.makeMovie()
        let watchlist = Watchlist(name: "Weekend", details: "", movies: [])

        watchlist.toggle(movie)
        XCTAssertTrue(watchlist.contains(movie))

        watchlist.toggle(movie)
        XCTAssertFalse(watchlist.contains(movie))
    }

    func test_recentlyViewed_sortsNewestFirst() {
        let oldest = makeMovie(id: 1, title: "Oldest")
        oldest.recentlyViewedAt = Date(timeIntervalSince1970: 10)
        let newest = makeMovie(id: 2, title: "Newest")
        newest.recentlyViewedAt = Date(timeIntervalSince1970: 20)
        let unviewed = makeMovie(id: 3, title: "Unviewed")

        XCTAssertEqual([oldest, newest, unviewed].recentlyViewed.map(\.id), [2, 1])
    }

    func test_markRecentlyViewed_capsStoredMovies() throws {
        let context = try makeContext()
        let movies = (0..<14).map { index in
            makeMovie(id: index, title: "Movie \(index)")
        }
        movies.forEach(context.insert)

        for movie in movies {
            context.markRecentlyViewed(movie, limit: 12)
        }

        let recentlyViewed = movies.recentlyViewed
        XCTAssertEqual(recentlyViewed.count, 12)
        XCTAssertFalse(recentlyViewed.contains { $0.id == 0 })
        XCTAssertFalse(recentlyViewed.contains { $0.id == 1 })
    }

    func test_movieSortOptions_orderMovies() {
        let alpha = makeMovie(id: 1, title: "Alpha", rating: 7, releaseDate: "2020-01-01")
        let beta = makeMovie(id: 2, title: "Beta", rating: 9, releaseDate: "2018-01-01")
        let gamma = makeMovie(id: 3, title: "Gamma", rating: 8, releaseDate: "2024-01-01")
        let movies = [beta, gamma, alpha]

        XCTAssertEqual(movies.sorted(by: .title).map(\.title), ["Alpha", "Beta", "Gamma"])
        XCTAssertEqual(movies.sorted(by: .rating).map(\.title), ["Beta", "Gamma", "Alpha"])
        XCTAssertEqual(movies.sorted(by: .releaseYear).map(\.title), ["Gamma", "Alpha", "Beta"])
    }

    func test_watchlistSortOptions_orderWatchlists() {
        let movie = APICallerTests.sampleMovieDTO.makeMovie()
        let short = Watchlist(name: "Short", details: "", movies: [movie])
        let long = Watchlist(name: "Long", details: "", movies: [movie, makeMovie(id: 99, title: "Extra")])
        let empty = Watchlist(name: "Empty", details: "", movies: [])
        let watchlists = [short, long, empty]

        XCTAssertEqual(watchlists.sorted(by: .title).map(\.title), ["Empty", "Long", "Short"])
        XCTAssertEqual(watchlists.sorted(by: .count).map(\.title), ["Long", "Short", "Empty"])
    }

    private func makeMovie(
        id: Int,
        title: String,
        rating: Double = 0,
        releaseDate: String? = nil
    ) -> Movie {
        Movie(
            id: id,
            title: title,
            overview: "",
            posterPath: nil,
            backdropPath: nil,
            voteAverage: rating,
            releaseDate: releaseDate,
            isWatched: false,
            isBookmarked: false
        )
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
