//
//  MovieTests.swift
//  SwiftFlixTests
//
//  Created by Kabir Dhillon on 9/18/23.
//

import XCTest
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
}
