//
//  MovieViewModelTests.swift
//  SwiftFlixTests
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
    
    func test_nowPlayingMovies_shouldNotBeNil() {
        moviesVM.fetchNowPlayingMovies()
        XCTAssertNotNil(moviesVM.nowPlayingMovies)
    }
    
    func test_upcomingMovies_shouldNotBeNil() {
        moviesVM.fetchUpcomingMovies()
        XCTAssertNotNil(moviesVM.nowPlayingMovies)
    }
}
