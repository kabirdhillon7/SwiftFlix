//
//  SavedMovie.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 8/25/23.
//

import Foundation
import SwiftUI

/// Saved Movie
final class SavedMovie: ObservableObject {
    /// A set of saved Movie objects
    @Published var movies: Set<Movie>
    
    /// UserDefaults save key
    private let saveKey = "SavedMovies"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()
                // Decode Movie
                let movieArray = try decoder.decode([Movie].self, from: data)
                movies = Set(movieArray)
            } catch {
                print("Unable to Decode Saved Movies: (\(error))")
                movies = Set<Movie>()
            }
        } else {
            movies = Set<Movie>()
        }
    }
    
    /// Check if the movies set contains a particular movie
    ///
    /// - Parameters: movie: A Movie.
    /// - Returns: A Bool if the movies set contains the specified movie.
    func contains(_ movie: Movie) -> Bool {
        movies.contains(movie)
    }
    
    /// Adds a movie to movie set
    ///
    /// - Parameters: movie: A movie to be added to the movies set.
    func add(_ movie: Movie) {
        objectWillChange.send()
        movies.insert(movie)
        save()
    }
    
    /// Removes a movie to movie set
    /// - Parameters: movie: A movie.
    func remove(_ movie: Movie) {
        objectWillChange.send()
        movies.remove(movie)
        save()
    }
    
    /// Saves and updates to UserDefaults
    func save() {
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()
            // Convert Set to Array
            let movieArray = Array(movies)
            // Encode Saved Movies
            let data = try encoder.encode(movieArray)
            // Save to UserDefaults
            UserDefaults.standard.set(data, forKey: saveKey)
        } catch {
            print("Unable to Encode Saved Movies set (\(error))")
        }
    }
}
