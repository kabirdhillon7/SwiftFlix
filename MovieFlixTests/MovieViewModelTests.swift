//
//  MovieViewModelTests.swift
//  MovieFlixTests
//
//  Created by Kabir Dhillon on 8/25/23.
//

import XCTest
import Combine
@testable import MovieFlix

class MockAPIService: DataServicing {
    
    var mockTrailerKey = ""
    var cancellables = Set<AnyCancellable>()
    
    func getMovies(toUrl url: URL) -> AnyPublisher<[Movie], Error> {
        Result.Publisher([]).eraseToAnyPublisher()
    }
    
    func getMovieTrailer(movieId: Int) -> AnyPublisher<String, Error> {
        Result.Publisher(mockTrailerKey).eraseToAnyPublisher()
    }
    
    func getSearchMovieResults(searchQuery: String) -> AnyPublisher<[MovieFlix.Movie], Error> {
        Result.Publisher([]).eraseToAnyPublisher()
    }
}

final class MovieViewModelTests: XCTestCase {
    
    private var moviesVM: MovieViewModel!
    private var mockAPIService: MockAPIService!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        moviesVM = MovieViewModel()
    }
    
    override func tearDown() {
        moviesVM = nil
        super.tearDown()
        
    }
    
    func test_movies_shouldNotBeNil() {
        moviesVM.fetchMovies()
        XCTAssertNotNil(moviesVM.movies)
    }
}
