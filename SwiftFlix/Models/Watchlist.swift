//
//  WatchListMovie.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 2/19/24.
//

import Foundation

final class Watchlist: ObservableObject, Codable {
    var id: UUID
    var name: String
    @Published var moviesList: Set<Movie>
    
    private let watchlistSaveKey: String
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.watchlistSaveKey = "\(self.id)"
        
        if let data = UserDefaults.standard.data(forKey: watchlistSaveKey) {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()
                // Decode Movie
                let movieArray = try decoder.decode([Movie].self, from: data)
                moviesList = Set(movieArray)
            } catch {
                print("Unable to Decode Saved Movies: (\(error))")
                moviesList = Set<Movie>()
            }
        } else {
            moviesList = Set<Movie>()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, moviesList, watchlistSaveKey
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let moviesArray = try container.decode([Movie].self, forKey: .moviesList)
        moviesList = Set(moviesArray)
        watchlistSaveKey = try container.decode(String.self, forKey: .watchlistSaveKey)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(moviesList, forKey: .moviesList)
        try container.encode(watchlistSaveKey, forKey: .watchlistSaveKey)
    }
    
    /// Check if the movies set contains a particular movie
    ///
    /// - Parameters: movie: A Movie.
    /// - Returns: A Bool if the movies set contains the specified movie.
    func contains(_ movie: Movie) -> Bool {
        moviesList.contains(movie)
    }
    
    /// Adds a movie to movie set
    ///
    /// - Parameters: movie: A movie to be added to the movies set.
    func add(_ movie: Movie) {
        //        objectWillChange.send()
        moviesList.insert(movie)
        save()
    }
    
    /// Removes a movie to movie set
    ///
    /// - Parameters: movie: A movie.
    func remove(_ movie: Movie) {
        //        objectWillChange.send()
        moviesList.remove(movie)
        save()
    }
    
    /// Saves and updates to UserDefaults
    func save() {
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()
            // Convert Set to Array
            let movieArray = Array(moviesList)
            // Encode Saved Movies
            let data = try encoder.encode(movieArray)
            // Save to UserDefaults
            UserDefaults.standard.set(data, forKey: watchlistSaveKey)
        } catch {
            print("Unable to Encode Saved Movies set (\(error))")
        }
    }
}
