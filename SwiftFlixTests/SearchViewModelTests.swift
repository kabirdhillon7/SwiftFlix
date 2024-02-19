//
//  SearchViewModelTests.swift
//  SwiftFlixTests
//
//  Created by Kabir Dhillon on 2/17/24.
//

import XCTest
@testable import MovieFlix

final class SearchViewModelTests: XCTestCase {
    
    private var searchVM: SearchViewModel!
    private var mockAPIService: MockAPIService!

    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        searchVM = SearchViewModel()
    }

    override func tearDown() {
        searchVM = nil
        super.tearDown()
    }
    
    func test_searchMovies_shouldNotBeNil() {
        searchVM.searchMovies()
        XCTAssertNotNil(searchVM.searchResults)
    }
}
