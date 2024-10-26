//
//  SearchViewModel.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 2/17/24.
//

import Foundation
import Combine

/// A view model responsible for managing movie search data and API calls
@Observable
final class SearchViewModel {
    var searchQuery: String = ""
    var searchResults = [Movie]()
    
    private let apiCaller: APICaller = APICaller()
    
    /// Fetches search results from API
    @MainActor
    func searchMovies() async {
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=\(APIInformation.key.rawValue)&query=\(encodedQuery)"
        
        do {
            searchResults = try await apiCaller.getData(urlString: urlString, decoderType: MovieResults.self).results
        } catch {
            print("Search error: \(error.localizedDescription)")
        }
    }
}
