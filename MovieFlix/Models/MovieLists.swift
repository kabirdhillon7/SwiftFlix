//
//  SavedViewModel.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 8/25/23.
//

import Foundation

/// A data model responsible for managing movie list data
final class MovieLists: ObservableObject {
    @Published var savedMovies: MovieManager = MovieManager(saveKey: "QueueMovies")
    @Published var watchedMovies: MovieManager = MovieManager(saveKey: "WatchedMovies")
}
