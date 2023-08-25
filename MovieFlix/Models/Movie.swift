//
//  Movie.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import Foundation

/// Movie
struct Movie: Decodable, Identifiable {
    
    let id: Int
    let title: String
    let overview: String
    let poster_path: String
    let backdrop_path: String
    let vote_average: Double
}

/// Movie Results from The Movie Database
struct MovieResults: Decodable {
    let results: [Movie]
}
