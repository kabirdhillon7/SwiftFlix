//
//  Movie.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import Foundation

/// Movie
struct Movie: Codable, Identifiable, Hashable, Equatable {
    
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
    
//    private enum CodingKeys: String, CodingKey {
//        case id, title, overview
//        case posterPath = "poster_path"
//        case backdropPath = "backdrop_path"
//        case voteAverage = "vote_average"
//    }
    
    init(id: Int, title: String, overview: String, posterPath: String?, backdropPath: String?, voteAverage: Double) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.voteAverage = voteAverage
    }
    
//    init(from decoder: any Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(Int.self, forKey: .id)
//        self.title = try container.decode(String.self, forKey: .title)
//        self.overview = try container.decode(String.self, forKey: .overview)
//        self.posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
//        self.backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath)
//        self.voteAverage = try container.decode(Double.self, forKey: .voteAverage)
//    }
//    
//    func encode(to encoder: any Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(Int.self, forKey: .id)
//        try container.encode(String.self, forKey: .title)
//        try container.encode(String.self, forKey: .overview)
//        try container.encode(String.self, forKey: .posterPath)
//        try container.encode(String.self, forKey: .backdropPath)
//        try container.encode(Double.self, forKey: .voteAverage)
//    }
}

/// Movie Results from The Movie Database
struct MovieResults: Codable {
    let results: [Movie]
}
