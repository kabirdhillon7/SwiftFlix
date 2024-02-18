//
//  SearchViewModel.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 2/17/24.
//

import Foundation
import Combine

/// A view model responsible for managing movie search data and API calls
final class SearchViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults = [Movie]()
    
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
