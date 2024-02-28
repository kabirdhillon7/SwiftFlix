//
//  SearchToAddToWatchListViewModel.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 2/19/24.
//

import Foundation
import Combine

final class SearchToAddToWatchListViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults = [Movie]()
    
    @Published var selectedMovies = Set<Movie>()
    
    private let apiCaller: APICaller = APICaller()
    private var cancellables = Set<AnyCancellable>()
    
    /// Fetches search results from API
    func searchMovies() {
        apiCaller.getSearchMovieResults(searchQuery: searchQuery)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Search error: \(error.localizedDescription)")
                }
            } receiveValue: { movies in
                self.searchResults = movies
            }
            .store(in: &cancellables)
    }
}
