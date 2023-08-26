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
    @Published var movies: Set<Movie>
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
                print("Unable to Decode Saved Movies (\(error))")
                movies = Set<Movie>()
            }
        } else {
            movies = Set<Movie>()
        }
    }
    
    /// Check if the movies set contains a particular movie
    func contains(_ movie: Movie) -> Bool {
        movies.contains(movie)
    }
    
    /// Adds a movie to movie set
    func add(_ movie: Movie) {
        objectWillChange.send()
        movies.insert(movie)
        print("Set - Added: \(movies)")
        save()
    }
    
    // removes the movie from our set, updates all views, and saves the change
    /// Removes a movie to movie set
    func remove(_ movie: Movie) {
        objectWillChange.send()
        movies.remove(movie)
        print("Set - Removed: \(movies)")
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