//
//  APICallerTests.swift
//  MovieFlixTests
//
//  Created by Kabir Dhillon on 8/29/23.
//

import XCTest
import Combine
@testable import MovieFlix

final class MockAPIService: DataServicing {
    
    var mockTrailerKey = ""
    var cancellables = Set<AnyCancellable>()
    
    func getNowPlayingMovies(toUrl url: URL) -> AnyPublisher<[Movie], Error> {
        Result.Publisher([]).eraseToAnyPublisher()
    }
    
    func getMovieTrailer(movieId: Int) -> AnyPublisher<String, Error> {
        Result.Publisher(mockTrailerKey).eraseToAnyPublisher()
    }
    
    func getSearchMovieResults(searchQuery: String) -> AnyPublisher<[MovieFlix.Movie], Error> {
        Result.Publisher([]).eraseToAnyPublisher()
    }
    
    func getMovieRecommendations(movieID: Int) -> AnyPublisher<[MovieFlix.Movie], Error> {
        Result.Publisher([]).eraseToAnyPublisher()
    }
}

final class APICallerTests: XCTestCase {

    private var apiCaller: APICaller!
    
    override func setUp() {
        super.setUp()
        apiCaller = APICaller()
    }
    
    override func tearDown() {
        apiCaller = nil
        super.tearDown()
    }

    func test_getMovies_shouldNotBeNil() {
        // given
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=") else {
            return
        }
        
        XCTAssertNotNil(apiCaller.getNowPlayingMovies(toUrl: url))
    }
    
    func test_getMovieTrailer_shouldNotBeNil() {
        XCTAssertNotNil(apiCaller.getMovieTrailer(movieId: 502356))
    }
    
    func test_getSearchMovieResults_shouldNotBeNil() {
        XCTAssertNotNil(apiCaller.getSearchMovieResults(searchQuery: "Lord of the Rings"))
    }
}
