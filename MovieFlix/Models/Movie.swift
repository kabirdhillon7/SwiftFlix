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
    let poster_path: String?
    let backdrop_path: String?
    let vote_average: Double
    
    init(id: Int, title: String, overview: String, poster_path: String, backdrop_path: String, vote_average: Double) {
        self.id = id
        self.title = title
        self.overview = overview
        self.poster_path = poster_path
        self.backdrop_path = backdrop_path
        self.vote_average = vote_average
    }
}

/// Movie Results from The Movie Database
struct MovieResults: Decodable {
    let results: [Movie]
}
