//
//  MovieListViewModel.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 2/19/24.
//

import Observation

/// A view model class for managing the list of movies.
@MainActor
@Observable
final class MovieListViewModel {
    var movieList = Set<Movie>()

    init(movieList: Set<Movie>) {
        self.movieList = movieList
    }
}
