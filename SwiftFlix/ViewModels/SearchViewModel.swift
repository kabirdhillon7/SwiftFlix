//
//  SearchViewModel.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 2/17/24.
//

import Observation
import SwiftData

@MainActor
@Observable
final class SearchViewModel {
    var searchQuery = ""
    private(set) var phase = LoadingPhase.idle
    private(set) var searchResults = [Movie]()

    @ObservationIgnored private let client: any TMDBClientProtocol
    @ObservationIgnored private var searchTask: Task<Void, Never>?

    init(client: any TMDBClientProtocol = TMDBClient()) {
        self.client = client
    }

    deinit {
        searchTask?.cancel()
    }

    func searchDebounced(modelContext: ModelContext) {
        searchTask?.cancel()
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            searchResults = []
            phase = .idle
            return
        }

        searchTask = Task { @MainActor [weak self] in
            do {
                try await Task.sleep(for: .milliseconds(350))
                await self?.search(query: query, modelContext: modelContext)
            } catch { }
        }
    }

    func searchImmediately(modelContext: ModelContext) async {
        searchTask?.cancel()
        await search(query: searchQuery, modelContext: modelContext)
    }

    func clear() {
        searchTask?.cancel()
        searchResults = []
        phase = .idle
    }

    private func search(query: String, modelContext: ModelContext) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            clear()
            return
        }

        phase = .loading
        do {
            let dtos = try await client.searchMovies(query: trimmedQuery)
            searchResults = modelContext.movies(matching: dtos)
            try? modelContext.save()
            phase = searchResults.isEmpty ? .empty : .loaded
        } catch is CancellationError {
            phase = .idle
        } catch {
            searchResults = []
            phase = .failed(error.localizedDescription)
        }
    }
}
