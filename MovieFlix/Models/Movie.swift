//
//  Movie.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import Foundation

/// Movie
struct Movie: Codable, Identifiable, Hashable {
    
    let id: Int
    let title: String
    let overview: String
    let poster_path: String
    let backdrop_path: String
    let vote_average: Double
    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        
//        id = try container.decode(Int.self, forKey: .id)
//        title = try container.decode(String.self, forKey: .title)
//        overview = try container.decode(String.self, forKey: .overview)
//        poster_path = try container.decode(String.self, forKey: .poster_path)
//        backdrop_path = try container.decode(String.self, forKey: .backdrop_path)
//        vote_average = try container.decode(Double.self, forKey: .vote_average)
//    }
//    
//    private enum CodingKeys: String, CodingKey {
//        case id, title, overview, poster_path, backdrop_path, vote_average, results
//    }
}

/// Movie Results from The Movie Database
struct MovieResults: Decodable {
    let results: [Movie]
}
