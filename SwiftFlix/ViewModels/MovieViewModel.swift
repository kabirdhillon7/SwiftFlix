//
//  MovieViewModel.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import Foundation
import Combine

/// A view model responsible for managing movie data and API calls
@Observable
final class MovieViewModel {
    var nowPlayingMovies = [Movie]()
    var popularMovies = [Movie]()
    var upcomingMovies = [Movie]()
    
    var filteredPopularMovies: [Movie] {
        popularMovies.filter {
            !nowPlayingMovies.contains($0) && !upcomingMovies.contains($0)
        }
    }
    
    var filteredUpcomingMovies: [Movie] {
        upcomingMovies.filter {
            !nowPlayingMovies.contains($0) && !popularMovies.contains($0)
        }
    }
    
    var linkedMovie: Movie?
    var presentDetailViewForLink = false
    var presentLinkError = false
    
    private let apiCaller: APICaller = APICaller()
    private var cancellables: Set<AnyCancellable> = []
        
    /// Fetches a list of movies now playing in theaters
    func fetchNowPlayingMovies() {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=") else { return }
        
        apiCaller.getNowPlayingMovies(toUrl: url)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Finished getting now playing movies")
                case .failure(let error):
                    print("Error getting now playing movies: \(error)")
                }
            } receiveValue: { [weak self] movies in
                self?.nowPlayingMovies = movies
            }
            .store(in: &cancellables)
    }
    
    /// Fetches a list of movies now playing in theaters
    func fetchPopularMovies() {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=") else { return }
        
        apiCaller.getNowPlayingMovies(toUrl: url)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Finished getting now playing movies")
                case .failure(let error):
                    print("Error getting now playing movies: \(error)")
                }
            } receiveValue: { [weak self] movies in
                self?.popularMovies = movies
            }
            .store(in: &cancellables)
    }
    
    /// Fetches a list of movies upcoming in theaters
    func fetchUpcomingMovies() {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/upcoming?api_key=") else { return }
        
        apiCaller.getUpcomingMovies(toUrl: url)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Finished getting upcoming movies")
                case .failure(let error):
                    print("Error getting upcoming movies: \(error)")
                }
            } receiveValue: { [weak self] movies in
                guard let self = self else {
                    return
                }
                self.upcomingMovies = movies
            }
            .store(in: &cancellables)
    }
    
    /// Fetches a movie object from a movie ID
    func fetchMovieObject(movieId: Int) {
        apiCaller.getMovie(movieID: movieId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Finished getting movie details")
                case .failure(let error):
                    print("Error getting movie details: \(error)")
                    self.presentLinkError = true
                }
            } receiveValue: { [weak self] movie in
                guard let self = self else {
                    return
                }
                self.linkedMovie = movie
                self.presentDetailViewForLink = true
            }
            .store(in: &cancellables)
    }
}
