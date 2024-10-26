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
@Observable
final class MovieDetailViewModel {
    
    var movie: Movie
    var trailerKey: String?
    var watchProviderLinkString: String?
    
    var recommendedMovies = [Movie]()
    var movieCredits: Credits?
    
    private let apiCaller: APICaller = APICaller()
    private var cancellables = Set<AnyCancellable>()
    
    init(movie: Movie) {
        self.movie = movie
    }
    
    /// Fetches a the movie trailer for a particular movie
    @MainActor
    func fetchMovieTrailer() async {
        do {
            trailerKey = try await apiCaller.getMovieTrailer(movieId: movie.id)
        } catch {
            print("Error getting movie trailer: \(error)")
        }
    }
    
    /// Fetches a list of recommended movies for a particular movie
    @MainActor
    func fetchMovieRecommendations() async {
        let urlString = "https://api.themoviedb.org/3/movie/\(movie.id)/recommendations?api_key=\(APIInformation.key.rawValue)"
        
        do {
            recommendedMovies = try await apiCaller.getData(urlString: urlString, decoderType: MovieResults.self).results
        } catch {
            print("Error getting recommended movies: \(error)")
        }
    }
    
    /// Fetches a watch provider link for a particular movie
    @MainActor
    func fetchWatchProviderLink() async {
        let urlString = "https://api.themoviedb.org/3/movie/\(movie.id)/watch/providers?api_key=\(APIInformation.key.rawValue)"
        
        do {
            watchProviderLinkString = try await apiCaller.getWatchProviders(movieID: movie.id)
        } catch {
            print("Error getting watch provider link: \(error)")
        }
    }
    
    /// Fetches the credits for a particular movie
    @MainActor
    func fetchCredits() async {
        let urlString = "https://api.themoviedb.org/3/movie/\(movie.id)/credits?api_key=\(APIInformation.key.rawValue)"
        
        do {
            movieCredits = try await apiCaller.getData(urlString: urlString, decoderType: Credits.self)
        } catch {
            print("Error getting credits: \(error)")
        }
    }
}
