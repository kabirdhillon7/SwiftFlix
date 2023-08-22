//
//  SearchView.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 6/24/23.
//

import SwiftUI
import Combine

struct SearchView: View {
    @State var searchQuery = ""
    @State var searchResults = [Movie]()
    
    @FocusState private var nameIsFocused: Bool
    
    private let apiCaller: APICaller = APICaller()
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        NavigationStack {
            TextField("Search movies", text: $searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .onChange(of: searchQuery, perform: { newValue in
                    searchMovies()
                })
                .focused($nameIsFocused)
                .onTapGesture {
                    hideKeyboard()
                }
            List {
                ForEach(searchResults) { movie in
                    NavigationLink(destination: MovieDetailView(movie: movie)) {
                        HStack {
                            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + movie.poster_path))
                            Text(movie.title)
                                .bold()
                        }
                    }
                }.listRowInsets(EdgeInsets())
                
            }
            .listStyle(.plain)
            .navigationTitle("Search")
        }
    }
    
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

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}
