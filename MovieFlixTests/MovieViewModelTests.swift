//
//  MovieViewModelTests.swift
//  MovieFlixTests
//
//  Created by Kabir Dhillon on 8/25/23.
//

import XCTest
@testable import MovieFlix

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
