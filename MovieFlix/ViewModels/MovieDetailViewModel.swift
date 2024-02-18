//
//  MovieDetailViewModel.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 2/17/24.
//

import Foundation
import Combine

/// A view model responsible for movie information and data
final class MovieDetailViewModel: ObservableObject {
    
    var movie: Movie
    
    var trailerKey: String?
    @Published var recommendedMovies = [Movie]()
    
    private let apiCaller: APICaller = APICaller()
    private var cancellables = Set<AnyCancellable>()
    
    init(movie: Movie) {
        self.movie = movie
    }
    
    /// Fetches a the movie trailer for a particular movie
    func fetchMovieTrailer() {
        apiCaller.getMovieTrailer(movieId: movie.id)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error getting movie trailer: \(error)")
                }
            } receiveValue: { videoID in
                self.trailerKey = videoID
            }
            .store(in: &cancellables)
    }
    
    /// Fetches a list of recommended movies for a particular movie
    func fetchMovieRecommendations() {
        apiCaller.getMovieRecommendations(movieID: movie.id)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Finished getting recommended movies")
                case .failure(let error):
                    print("Error getting recommended movies: \(error)")
                }
            } receiveValue: { movies in
                self.recommendedMovies = movies
            }
            .store(in: &cancellables)
    }
}
