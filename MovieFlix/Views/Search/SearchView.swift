//
//  SearchView.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 6/24/23.
//

import SwiftUI
import Combine

/// A view that displays  a search interface for movies
struct SearchView: View {
    @State var searchQuery = ""
    @State var searchResults = [Movie]()
    
    private let apiCaller: APICaller = APICaller()
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(searchResults) { movie in
                    NavigationLink(destination: MovieDetailView(movie: movie)) {
                        HStack(spacing: 5) {
                            if let posterPath = movie.poster_path {
                                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath)) { image in
                                    
                                    image
                                        .resizable()
                                        .frame(width: 92.5, height: 138.75)
                                        .aspectRatio(contentMode: .fill)
                                        .cornerRadius(15)
                                        .padding()
                                    
                                } placeholder: {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .frame(width: 92.5, height: 138.75)
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(15)
                                        .padding()
                                }
                            }
                            
                            VStack {
                                Text(movie.title)
                                    .font(.system(size: 20))
                                    .bold()
                                    .frame(maxWidth: .infinity,alignment: .leading)
                                Spacer()
                                    .frame(height: 5)
                                Text(movie.overview)
                                    .font(.body)
                                    .frame(maxWidth: .infinity,alignment: .leading)
                                    .lineLimit(4)
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets())
            }
            .searchable(text: $searchQuery, prompt: "Search movies")
            .onSubmit(of: .search) {
                searchMovies()
            }
            .onChange(of: searchQuery) {
                if searchQuery.isEmpty {
                    searchResults.removeAll()
                } else {
                    searchMovies()
                }
            }
            .listStyle(.plain)
            .navigationTitle("Search")
        }
    }
    
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

#Preview {
    SearchView()
    
}

// MARK: Hides the Keyboard When Not In Use
extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}
