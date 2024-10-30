//
//  MovieViewModel.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import SwiftData

/// A view model responsible for managing movie data and API calls
extension MovieView {
    @Observable
    final class ViewModel {
        var modelContext: ModelContext
        
        private(set) var nowPlayingMovies = [Movie]()
        private(set) var popularMovies = [Movie]()
        private(set) var upcomingMovies = [Movie]()
//        var filteredPopularMovies: [Movie] {
//            popularMovies.filter {
//                !nowPlayingMovies.contains($0) && !upcomingMovies.contains($0)
//            }
//        }
//        var filteredUpcomingMovies: [Movie] {
//            upcomingMovies.filter {
//                !nowPlayingMovies.contains($0) && !popularMovies.contains($0)
//            }
//        }
        
        private let apiCaller: APICaller
        
        init(modelContext: ModelContext, apiCaller: APICaller) {
            self.modelContext = modelContext
            self.apiCaller = apiCaller
        }
        
        /// Fetches a list of movies now playing in theaters
        @MainActor
        func fetchNowPlayingMovies() async {
            let urlString = "https://api.themoviedb.org/3/movie/now_playing?api_key=\(APIInformation.key.rawValue)"
            
            do {
                let fetchedMovies = try await apiCaller.getData(urlString: urlString, decoderType: MovieResults.self).results
                for movie in fetchedMovies where !nowPlayingMovies.contains(where: { $0.id == movie.id }) {
                    modelContext.insert(movie)
                }
                nowPlayingMovies = fetchedMovies
            } catch {
                print("Error getting now playing movies: \(error)")
            }
        }
        
        /// Fetches a list of movies now playing in theaters
        @MainActor
        func fetchPopularMovies() async {
            let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(APIInformation.key.rawValue)"
            
            do {
                let fetchedMovies = try await apiCaller.getData(urlString: urlString, decoderType: MovieResults.self).results
                for movie in fetchedMovies where !popularMovies.contains(where: { $0.id == movie.id }) {
                    modelContext.insert(movie)
                }
                popularMovies = fetchedMovies
            } catch {
                print("Error getting now playing movies: \(error)")
            }
        }
        
        /// Fetches a list of movies upcoming in theaters
        @MainActor
        func fetchUpcomingMovies() async {
            let urlString = "https://api.themoviedb.org/3/movie/upcoming?api_key=\(APIInformation.key.rawValue)"
            
            do {
                let fetchedMovies = try await apiCaller.getData(urlString: urlString, decoderType: MovieResults.self).results
                for movie in fetchedMovies where !upcomingMovies.contains(where: { $0.id == movie.id }) {
                    modelContext.insert(movie)
                }
                upcomingMovies = fetchedMovies
            } catch {
                print("Error getting now playing movies: \(error)")
            }
        }
    }
}
