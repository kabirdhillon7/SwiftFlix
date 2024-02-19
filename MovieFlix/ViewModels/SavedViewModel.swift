//
//  SavedViewModel.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 8/25/23.
//

import Foundation

/// A view model responsible for managing saved movie data
final class SavedViewModel: ObservableObject {
    @Published var queuedMovie: SavedMovie = SavedMovie(saveKey: "QueueMovies")
    @Published var watchedMovies: SavedMovie = SavedMovie(saveKey: "WatchedMovies")
}
