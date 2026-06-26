//
//  Watchlist.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 11/11/24.
//

import Foundation
import SwiftData

@Model
final class Watchlist: Identifiable, Hashable {
    @Attribute(.unique) var id: UUID
    var title: String
    var details: String
    @Relationship(deleteRule: .cascade) var movies: [Movie]

    init(name: String, details: String, movies: [Movie]) {
        self.id = UUID()
        self.title = name
        self.details = details
        self.movies = movies
    }

    func contains(_ movie: Movie) -> Bool {
        movies.contains { $0.id == movie.id }
    }

    func toggle(_ movie: Movie) {
        if let index = movies.firstIndex(where: { $0.id == movie.id }) {
            movies.remove(at: index)
        } else {
            movies.append(movie)
        }
    }
}

@Model
final class WatchlistCollection: Identifiable, Hashable {
    @Attribute(.unique) var id: UUID
    @Relationship(deleteRule: .cascade) var watchlists: [Watchlist]

    init(watchlists: [Watchlist]) {
        self.id = UUID()
        self.watchlists = watchlists
    }
}
