//
//  APICallerTests.swift
//  SwiftFlixTests
//
//  Created by Kabir Dhillon on 8/29/23.
//

import XCTest
@testable import SwiftFlix

final class MockHTTPClient: HTTPClient {
    var result: Result<(Data, HTTPURLResponse), Error>
    private(set) var requests = [URLRequest]()

    init(
        data: Data = APICallerTests.movieResultsJSON,
        statusCode: Int = 200,
        url: URL = URL(string: "https://api.themoviedb.org/3/movie/now_playing")!
    ) {
        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        self.result = .success((data, response))
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        requests.append(request)
        return try result.get()
    }
}

struct MockTMDBClient: TMDBClientProtocol {
    var moviesByCategory: [MovieCategory: [MovieDTO]] = [:]
    var searchResults = [MovieDTO]()
    var movieResult = APICallerTests.sampleMovieDTO
    var trailer: String? = "abc123"
    var recommendationsResult = [MovieDTO]()
    var creditsResult = Credits(cast: [], crew: [])
    var watchProviderResult: URL? = URL(string: "https://example.com/watch")
    var error: Error?

    func movies(in category: MovieCategory) async throws -> [MovieDTO] {
        if let error { throw error }
        return moviesByCategory[category, default: []]
    }

    func searchMovies(query: String) async throws -> [MovieDTO] {
        if let error { throw error }
        return searchResults
    }

    func movie(id: Int) async throws -> MovieDTO {
        if let error { throw error }
        return movieResult
    }

    func trailerKey(movieID: Int) async throws -> String? {
        if let error { throw error }
        return trailer
    }

    func recommendations(movieID: Int) async throws -> [MovieDTO] {
        if let error { throw error }
        return recommendationsResult
    }

    func credits(movieID: Int) async throws -> Credits {
        if let error { throw error }
        return creditsResult
    }

    func watchProviderLink(movieID: Int, countryCode: String) async throws -> URL? {
        if let error { throw error }
        return watchProviderResult
    }
}

final class APICallerTests: XCTestCase {
    static let sampleMovieDTO = MovieDTO(
        id: 502356,
        title: "The Super Mario Bros. Movie",
        overview: "A colorful adventure.",
        posterPath: "/poster.jpg",
        backdropPath: "/backdrop.jpg",
        voteAverage: 7.7,
        releaseDate: "2023-04-05"
    )

    static let movieResultsJSON = """
    {
      "results": [
        {
          "id": 502356,
          "title": "The Super Mario Bros. Movie",
          "overview": "A colorful adventure.",
          "poster_path": "/poster.jpg",
          "backdrop_path": "/backdrop.jpg",
          "vote_average": 7.7,
          "release_date": "2023-04-05"
        }
      ]
    }
    """.data(using: .utf8)!

    func test_movies_buildsCategoryURL() async throws {
        let httpClient = MockHTTPClient()
        let client = TMDBClient(
            configuration: TMDBConfiguration(apiKey: "test_key"),
            httpClient: httpClient
        )

        let movies = try await client.movies(in: .nowPlaying)

        XCTAssertEqual(movies, [Self.sampleMovieDTO])
        let url = try XCTUnwrap(httpClient.requests.first?.url)
        XCTAssertEqual(url.path, "/3/movie/now_playing")
        XCTAssertTrue(url.absoluteString.contains("api_key=test_key"))
    }

    func test_search_encodesQuery() async throws {
        let httpClient = MockHTTPClient()
        let client = TMDBClient(
            configuration: TMDBConfiguration(apiKey: "test_key"),
            httpClient: httpClient
        )

        _ = try await client.searchMovies(query: "Lord of the Rings")

        let components = URLComponents(url: try XCTUnwrap(httpClient.requests.first?.url), resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.path, "/3/search/movie")
        XCTAssertEqual(components?.queryItems?.first { $0.name == "query" }?.value, "Lord of the Rings")
    }

    func test_httpStatus_throwsStatusError() async {
        let httpClient = MockHTTPClient(statusCode: 500)
        let client = TMDBClient(
            configuration: TMDBConfiguration(apiKey: "test_key"),
            httpClient: httpClient
        )

        do {
            _ = try await client.movies(in: .popular)
            XCTFail("Expected request to throw.")
        } catch let error as TMDBError {
            XCTAssertEqual(error, .httpStatus(500))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_invalidData_throwsDecodingError() async {
        let httpClient = MockHTTPClient(data: Data("not json".utf8))
        let client = TMDBClient(
            configuration: TMDBConfiguration(apiKey: "test_key"),
            httpClient: httpClient
        )

        do {
            _ = try await client.movies(in: .upcoming)
            XCTFail("Expected request to throw.")
        } catch is DecodingError {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_missingAPIKey_throwsBeforeRequest() async {
        let httpClient = MockHTTPClient()
        let client = TMDBClient(
            configuration: TMDBConfiguration(apiKey: ""),
            httpClient: httpClient
        )

        do {
            _ = try await client.movies(in: .popular)
            XCTFail("Expected missing API key error.")
        } catch let error as TMDBError {
            XCTAssertEqual(error, .missingAPIKey)
            XCTAssertTrue(httpClient.requests.isEmpty)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
