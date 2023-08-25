//
//  MovieViewModel.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import Foundation
import SwiftUI
import Combine

/// A view model responsible for managing movie data and API calls
final class MovieViewModel: ObservableObject {
    @Published var movies = [Movie]()
    
    private let apiCaller: APICaller = APICaller()
    private var cancellables: Set<AnyCancellable> = []
    
    /// Fetches a list of movies currently playing in theaters
    func fetchMovies() {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=") else { return }
        
        apiCaller.getMovies(toUrl: url)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Finished getting movies")
                case .failure(let error):
                    print("Error getting movies: \(error)")
                }
            } receiveValue: { [weak self] movies in
                self?.movies = movies
            }
            .store(in: &cancellables)
    }
}
