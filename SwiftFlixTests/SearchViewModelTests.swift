//
//  SearchViewModelTests.swift
//  SwiftFlixTests
//
//  Created by Kabir Dhillon on 2/17/24.
//

import SwiftData
import XCTest
@testable import SwiftFlix

@MainActor
final class SearchViewModelTests: XCTestCase {
    func test_searchImmediately_populatesResults() async throws {
        let context = try makeContext()
        let viewModel = SearchViewModel(client: MockTMDBClient(searchResults: [APICallerTests.sampleMovieDTO]))
        viewModel.searchQuery = "Mario"

        await viewModel.searchImmediately(modelContext: context)

        XCTAssertEqual(viewModel.phase, .loaded)
        XCTAssertEqual(viewModel.searchResults.map(\.id), [502356])
    }

    func test_searchDebounced_populatesResultsAfterDelay() async throws {
        let context = try makeContext()
        let viewModel = SearchViewModel(client: MockTMDBClient(searchResults: [APICallerTests.sampleMovieDTO]))
        viewModel.searchQuery = "Mario"

        viewModel.searchDebounced(modelContext: context)
        try await Task.sleep(for: .milliseconds(450))

        XCTAssertEqual(viewModel.phase, .loaded)
        XCTAssertEqual(viewModel.searchResults.count, 1)
    }

    func test_emptySearch_clearsResults() async throws {
        let context = try makeContext()
        let viewModel = SearchViewModel(client: MockTMDBClient(searchResults: [APICallerTests.sampleMovieDTO]))
        viewModel.searchQuery = "Mario"
        await viewModel.searchImmediately(modelContext: context)

        viewModel.searchQuery = ""
        viewModel.searchDebounced(modelContext: context)

        XCTAssertEqual(viewModel.phase, .idle)
        XCTAssertTrue(viewModel.searchResults.isEmpty)
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
