//
//  MovieListViewModel.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 2/19/24.
//

import Foundation

/// A view model class for managing the list of movies.
final class MovieListViewModel: ObservableObject {
    @Published var movieList = Set<Movie>()
    
    init(movieList: Set<Movie>) {
        self.movieList = movieList
    }
}
