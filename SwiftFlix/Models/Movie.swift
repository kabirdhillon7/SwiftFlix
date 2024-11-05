//
//  Movie.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import SwiftData

/// Movie Results from The Movie Database
struct MovieResults: Decodable {
    let results: [Movie]
}

/// Movie
@Model
final class Movie: Decodable, Identifiable, Hashable, Equatable, Sendable {
    
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    var isWatched: Bool
    var isBookmarked: Bool
    
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
    }
    
    init(id: Int, title: String, overview: String, posterPath: String?, backdropPath: String?, voteAverage: Double, isWatched: Bool, isBookmarked: Bool) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.voteAverage = voteAverage
        self.backdropPath = backdropPath
        self.voteAverage = voteAverage
        self.isWatched = isWatched
        self.isBookmarked = isBookmarked
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.overview = try container.decode(String.self, forKey: .overview)
        self.posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        self.backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath)
        self.voteAverage = try container.decode(Double.self, forKey: .voteAverage)
        self.isBookmarked = false
        self.isWatched = false
    }
}
