//
//  MovieViewModel.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import Observation
import SwiftData
import Foundation

enum LoadingPhase: Equatable {
    case idle
    case loading
    case loaded
    case empty
    case failed(String)

    var isLoading: Bool {
        self == .loading
    }
}

@MainActor
@Observable
final class MovieViewModel {
    private(set) var phase = LoadingPhase.idle
    private(set) var sections: [MovieCategory: [Movie]] = [:]

    @ObservationIgnored private let client: any TMDBClientProtocol

    init(client: any TMDBClientProtocol = TMDBClient()) {
        self.client = client
    }

    func movies(for category: MovieCategory) -> [Movie] {
        sections[category, default: []]
    }

    func loadHome(modelContext: ModelContext) async {
        guard !phase.isLoading else { return }

        let hadLoadedContent = !sections.values.joined().isEmpty
        phase = .loading
        do {
            async let nowPlayingDTOs = client.movies(in: .nowPlaying)
            async let popularDTOs = client.movies(in: .popular)
            async let upcomingDTOs = client.movies(in: .upcoming)

            let nowPlaying = modelContext.movies(matching: try await nowPlayingDTOs)
            let popular = modelContext.movies(matching: try await popularDTOs)
            let upcoming = modelContext.movies(matching: try await upcomingDTOs)
            let filteredPopular = popular.removingMovies(withIDs: Set(nowPlaying.map(\.id)))

            sections[.nowPlaying] = nowPlaying
            sections[.popular] = filteredPopular
            sections[.upcoming] = upcoming.removingMovies(withIDs: Set((nowPlaying + filteredPopular).map(\.id)))

            try? modelContext.save()
            phase = sections.values.joined().isEmpty ? .empty : .loaded
        } catch is CancellationError {
            phase = hadLoadedContent ? .loaded : .idle
        } catch let error as URLError where error.code == .cancelled {
            phase = hadLoadedContent ? .loaded : .idle
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }
}

private extension [Movie] {
    func removingMovies(withIDs ids: Set<Int>) -> [Movie] {
        filter { !ids.contains($0.id) }
    }
}
