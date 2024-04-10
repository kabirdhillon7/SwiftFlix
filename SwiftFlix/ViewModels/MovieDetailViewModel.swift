//
//  MovieDetailViewModel.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 2/17/24.
//

import Foundation
import Combine
import SwiftUI

/// A view model responsible for movie information and data
final class MovieDetailViewModel: ObservableObject {
    
    var movie: Movie
    var trailerKey: String?
    var watchProviderLinkString: String?
    
    @Published var recommendedMovies = [Movie]()
    @Published var movieCredits: Credits?
    
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
    
    /// Fetches a watch provider link for a particular movie
    func fetchWatchProviderLink() {
        apiCaller.getWatchProviders(movieID: movie.id)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Finished getting watch provider link")
                case .failure(let error):
                    print("Error getting watch provider link: \(error)")
                }
            } receiveValue: { link in
                print("Link: \(link)")
                self.watchProviderLinkString = link
            }
            .store(in: &cancellables)
    }
    
    /// Fetches the credits for a particular movie
    func fetchCredits() {
        apiCaller.fetchMovieCredits(movieID: movie.id)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Finished getting credits")
                case .failure(let error):
                    print("Error getting credits: \(error)")
                }
            } receiveValue: { credits in
                self.movieCredits = credits
            }
            .store(in: &cancellables)
    }
}
