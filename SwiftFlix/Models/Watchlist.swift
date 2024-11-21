//
//  Watchlist.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 11/11/24.
//

import Foundation
import SwiftData

@Model
final class Watchlist: Identifiable, Hashable, Sendable {
    @Attribute(.unique) let id: UUID
    var title: String
    var details: String
    @Relationship(deleteRule: .cascade) var movies: [Movie]
    
    init(name: String, details: String, movies: [Movie]) {
        self.id = UUID()
        self.title = name
        self.details = details
        self.movies = movies
    }
}

@Model
final class WatchlistCollection: Identifiable, Hashable, Sendable {
    @Attribute(.unique) let id: UUID
    @Relationship(deleteRule: .cascade) var watchlists: [Watchlist]
    
    init(watchlists: [Watchlist]) {
        self.id = UUID()
        self.watchlists = watchlists
    }
}
