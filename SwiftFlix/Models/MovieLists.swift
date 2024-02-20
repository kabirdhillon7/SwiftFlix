//
//  MovieLists.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 8/25/23.
//

import Foundation

/// A data model responsible for managing movie list data
final class MovieLists: ObservableObject {
    @Published var savedMovies: MovieManager
    @Published var watchedMovies: MovieManager
    @Published var watchLists: [Watchlist]
    
    init() {
        savedMovies = MovieManager(saveKey: "QueueMovies")
        watchedMovies = MovieManager(saveKey: "WatchedMovies")
        if let data = UserDefaults.standard.data(forKey: "WatchList") {
            do {
                let decoder = JSONDecoder()
                let watchListsArray = try decoder.decode([Watchlist].self, from: data)
                self.watchLists = watchListsArray
            } catch {
                print("Unable to load watch lists: \(error)")
                self.watchLists = []
            }
        } else {
            self.watchLists = [Watchlist]()
        }
    }
    
    func saveWatchLists() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(watchLists)
            UserDefaults.standard.set(data, forKey: "WatchList")
        } catch {
            print("Unable to save watch lists: \(error)")
        }
    }
    
    func loadWatchLists() {
        if let data = UserDefaults.standard.data(forKey: "WatchList") {
            do {
                let decoder = JSONDecoder()
                let watchListsArray = try decoder.decode([Watchlist].self, from: data)
                self.watchLists = watchListsArray
            } catch {
                print("Unable to load watchlists: \(error)")
                self.watchLists = []
            }
        } else {
            self.watchLists = []
        }
    }
}
