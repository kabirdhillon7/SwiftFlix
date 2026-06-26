//
//  MovieDetailViewModel.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 2/17/24.
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class MovieDetailViewModel {
    private(set) var phase = LoadingPhase.idle
    private(set) var trailerKey: String?
    private(set) var watchProviderLink: URL?
    private(set) var recommendedMovies = [Movie]()
    private(set) var credits: Credits?

    @ObservationIgnored private let client: any TMDBClientProtocol

    init(client: any TMDBClientProtocol = TMDBClient()) {
        self.client = client
    }

    func load(movie: Movie, modelContext: ModelContext) async {
        guard !phase.isLoading else { return }

        phase = .loading
        do {
            async let details = client.movie(id: movie.id)
            async let trailer = client.trailerKey(movieID: movie.id)
            async let recommendations = client.recommendations(movieID: movie.id)
            async let providers = client.watchProviderLink(movieID: movie.id, countryCode: "US")
            async let credits = client.credits(movieID: movie.id)

            movie.update(with: try await details)
            modelContext.markRecentlyViewed(movie)
            trailerKey = try await trailer
            watchProviderLink = try await providers
            recommendedMovies = modelContext.movies(matching: try await recommendations)
            self.credits = try await credits

            phase = .loaded
        } catch {
            modelContext.markRecentlyViewed(movie)
            phase = .failed(error.localizedDescription)
        }
    }

    func toggleBookmark(movie: Movie, modelContext: ModelContext) {
        movie.isBookmarked.toggle()
        try? modelContext.save()
    }

    func toggleWatched(movie: Movie, modelContext: ModelContext) {
        movie.isWatched.toggle()
        try? modelContext.save()
    }
}
