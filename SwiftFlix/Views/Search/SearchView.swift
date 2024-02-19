//
//  SearchView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 6/24/23.
//

import SwiftUI
import Combine

/// A view that displays search results for movies
struct SearchView: View {
    @StateObject var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.searchResults) { movie in
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
            .searchable(text: $viewModel.searchQuery, prompt: "Search movies")
            .onSubmit(of: .search) {
                viewModel.searchMovies()
            }
            .onChange(of: viewModel.searchQuery) {
                if viewModel.searchQuery.isEmpty {
                    viewModel.searchResults.removeAll()
                } else {
                    viewModel.searchMovies()
                }
            }
            .listStyle(.plain)
            .navigationTitle("Search")
        }
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